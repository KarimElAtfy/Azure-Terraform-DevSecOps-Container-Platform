import os
from datetime import datetime, timezone

from fastapi import FastAPI, HTTPException


APP_NAME = os.getenv("APP_NAME", "Azure DevSecOps Container Platform")
APP_VERSION = os.getenv("APP_VERSION", "0.1.0")
APP_ENV = os.getenv("APP_ENV", "local")
APP_REGION = os.getenv("APP_REGION", "local")
APP_RUNTIME = os.getenv("APP_RUNTIME", "local")
GIT_COMMIT_SHA = os.getenv("GIT_COMMIT_SHA", "local")

APP_SECRET_MESSAGE = os.getenv("APP_SECRET_MESSAGE")
APPLICATIONINSIGHTS_CONNECTION_STRING = os.getenv(
    "APPLICATIONINSIGHTS_CONNECTION_STRING"
)


app = FastAPI(
    title=APP_NAME,
    version=APP_VERSION,
    description="A containerized FastAPI application for an Azure DevSecOps platform demo.",
)


def utc_now() -> str:
    return datetime.now(timezone.utc).isoformat()


@app.get("/")
def root() -> dict:
    return {
        "app": APP_NAME,
        "version": APP_VERSION,
        "environment": APP_ENV,
        "runtime": APP_RUNTIME,
        "status": "running",
        "timestamp_utc": utc_now(),
    }


@app.get("/health")
def health() -> dict:
    return {
        "status": "healthy",
        "timestamp_utc": utc_now(),
    }


@app.get("/version")
def version() -> dict:
    return {
        "version": APP_VERSION,
        "commit_sha": GIT_COMMIT_SHA,
    }


@app.get("/config")
def config() -> dict:
    return {
        "environment": APP_ENV,
        "region": APP_REGION,
        "runtime": APP_RUNTIME,
        "app_insights_configured": bool(APPLICATIONINSIGHTS_CONNECTION_STRING),
    }


@app.get("/secret-status")
def secret_status() -> dict:
    return {
        "secret_reference": "configured" if APP_SECRET_MESSAGE else "missing",
        "secret_loaded": bool(APP_SECRET_MESSAGE),
        "secret_value_exposed": False,
    }


@app.get("/error-test")
def error_test() -> dict:
    raise HTTPException(
        status_code=500,
        detail="Controlled test error generated for observability validation.",
    )