import logging
import sys

from app.logging_context import get_request_id

_LOGGING_CONFIGURED = False


class RequestIdFilter(logging.Filter):
    def filter(self, record: logging.LogRecord) -> bool:
        record.request_id = get_request_id()
        return True


def configure_logging() -> logging.Logger:
    global _LOGGING_CONFIGURED

    logger = logging.getLogger("app")
    if _LOGGING_CONFIGURED:
        return logger

    handler = logging.StreamHandler(sys.stdout)
    handler.setLevel(logging.INFO)
    handler.setFormatter(
        logging.Formatter(
            "%(asctime)s %(levelname)s [%(request_id)s] %(name)s %(message)s"
        )
    )
    handler.addFilter(RequestIdFilter())

    logger.handlers.clear()
    logger.addHandler(handler)
    logger.setLevel(logging.INFO)
    logger.propagate = False
    _LOGGING_CONFIGURED = True
    return logger
