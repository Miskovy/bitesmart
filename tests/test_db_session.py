from sqlalchemy.exc import IntegrityError, OperationalError, SQLAlchemyError

from app.constants.ErrorCodes import ErrorCodes
from app.db.session import commit_session, flush_session
from app.exceptions.AppException import AppException
from app.exceptions.ConflictException import ConflictException


class FakeDB:
    def __init__(self, *, commit_error=None, flush_error=None):
        self.commit_error = commit_error
        self.flush_error = flush_error
        self.rollback_calls = 0

    def commit(self):
        if self.commit_error:
            raise self.commit_error

    def flush(self):
        if self.flush_error:
            raise self.flush_error

    def rollback(self):
        self.rollback_calls += 1


def test_commit_session_maps_integrity_errors_to_conflict():
    db = FakeDB(commit_error=IntegrityError("stmt", "params", Exception("duplicate")))

    try:
        commit_session(db, conflict_message="Duplicate food item.")
        raise AssertionError("Expected ConflictException")
    except ConflictException as exc:
        assert exc.message == "Duplicate food item."

    assert db.rollback_calls == 1


def test_commit_session_maps_operational_errors_to_service_unavailable():
    db = FakeDB(commit_error=OperationalError("stmt", "params", Exception("db offline")))

    try:
        commit_session(db, unavailable_message="Database temporarily unavailable.")
        raise AssertionError("Expected AppException")
    except AppException as exc:
        assert exc.error_code == ErrorCodes.SERVICE_UNAVAILABLE.name
        assert exc.message == "Database temporarily unavailable."

    assert db.rollback_calls == 1


def test_flush_session_maps_generic_sqlalchemy_errors_to_internal_error():
    db = FakeDB(flush_error=SQLAlchemyError("flush failed"))

    try:
        flush_session(db, internal_message="Could not create session row.")
        raise AssertionError("Expected AppException")
    except AppException as exc:
        assert exc.error_code == ErrorCodes.INTERNAL_ERROR.name
        assert exc.message == "Could not create session row."

    assert db.rollback_calls == 1
