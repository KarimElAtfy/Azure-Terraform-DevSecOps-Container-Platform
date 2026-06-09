import logging
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

logger = logging.getLogger("devsecops-api")
logger.setLevel(logging.INFO)

if APPLICATIONINSIGHTS_CONNECTION_STRING:
    try:
        from azure.monitor.opentelemetry import configure_azure_monitor

        configure_azure_monitor(
            connection_string=APPLICATIONINSIGHTS_CONNECTION_STRING,
            logger_name="devsecops-api",
        )

        logger.info("Azure Monitor OpenTelemetry instrumentation configured.")

    except Exception as exc:
        logger.warning(
            "Azure Monitor OpenTelemetry instrumentation could not be configured. "
            "The application will continue without telemetry export. Error: %s",
            exc,
        )
else:
    logger.info("Application Insights connection string not found. Telemetry export disabled.")

app = FastAPI(
    title=APP_NAME,
    version=APP_VERSION,
    description="A containerized FastAPI application for an Azure DevSecOps platform demo.",
)


def utc_now() -> str:
    return datetime.now(timezone.utc).isoformat()


@app.get("/")
def root() -> dict:
    logger.info("Root endpoint called.")

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
    logger.info("Version endpoint called.")

    return {
        "version": APP_VERSION,
        "commit_sha": GIT_COMMIT_SHA,
    }


@app.get("/config")
def config() -> dict:
    logger.info("Config endpoint called.")

    return {
        "environment": APP_ENV,
        "region": APP_REGION,
        "runtime": APP_RUNTIME,
        "app_insights_configured": bool(APPLICATIONINSIGHTS_CONNECTION_STRING),
    }


@app.get("/secret-status")
def secret_status() -> dict:
    logger.info("Secret status endpoint called.")

    return {
        "secret_reference": "configured" if APP_SECRET_MESSAGE else "missing",
        "secret_loaded": bool(APP_SECRET_MESSAGE),
        "secret_value_exposed": False,
    }


@app.get("/error-test")
def error_test() -> dict:
    logger.error("Controlled error endpoint called.")

    raise HTTPException(
        status_code=500,
        detail="Controlled test error generated for observability validation.",
    )