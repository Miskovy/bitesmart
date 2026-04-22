from sqlalchemy.exc import IntegrityError, OperationalError, SQLAlchemyError
from sqlalchemy.orm import Session

from app.constants.ErrorCodes import ErrorCodes
from app.exceptions.AppException import AppException
from app.exceptions.ConflictException import ConflictException


def commit_session(
    db: Session,
    *,
    conflict_message: str = "Database conflict occurred.",
    unavailable_message: str = "Database is unavailable.",
    internal_message: str = "Database operation failed.",
) -> None:
    try:
        db.commit()
    except IntegrityError as exc:
        db.rollback()
        raise ConflictException(conflict_message) from exc
    except OperationalError as exc:
        db.rollback()
        raise AppException(ErrorCodes.SERVICE_UNAVAILABLE, unavailable_message) from exc
    except SQLAlchemyError as exc:
        db.rollback()
        raise AppException(ErrorCodes.INTERNAL_ERROR, internal_message) from exc


def flush_session(
    db: Session,
    *,
    conflict_message: str = "Database conflict occurred.",
    unavailable_message: str = "Database is unavailable.",
    internal_message: str = "Database operation failed.",
) -> None:
    try:
        db.flush()
    except IntegrityError as exc:
        db.rollback()
        raise ConflictException(conflict_message) from exc
    except OperationalError as exc:
        db.rollback()
        raise AppException(ErrorCodes.SERVICE_UNAVAILABLE, unavailable_message) from exc
    except SQLAlchemyError as exc:
        db.rollback()
        raise AppException(ErrorCodes.INTERNAL_ERROR, internal_message) from exc
