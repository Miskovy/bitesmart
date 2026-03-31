"""Editing the Chat History

Revision ID: eb4bd3820b41
Revises:
Create Date: 2026-04-01 01:01:48.756793

"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = "eb4bd3820b41"
down_revision: Union[str, Sequence[str], None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "chat_sessions",
        sa.Column("id", sa.String(length=36), nullable=False),
        sa.Column("userId", sa.String(length=36), nullable=False),
        sa.Column("title", sa.String(length=255), nullable=True),
        sa.Column("createdAt", sa.DateTime(), nullable=False),
        sa.Column("updatedAt", sa.DateTime(), nullable=False),
        sa.ForeignKeyConstraint(["userId"], ["users.id"]),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(op.f("ix_chat_sessions_userId"), "chat_sessions", ["userId"], unique=False)

    op.create_table(
        "chat_messages",
        sa.Column("id", sa.String(length=36), nullable=False),
        sa.Column("sessionId", sa.String(length=36), nullable=False),
        sa.Column("role", sa.String(length=10), nullable=False),
        sa.Column("content", sa.Text(), nullable=False),
        sa.Column("createdAt", sa.DateTime(), nullable=False),
        sa.ForeignKeyConstraint(["sessionId"], ["chat_sessions.id"]),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(op.f("ix_chat_messages_sessionId"), "chat_messages", ["sessionId"], unique=False)


def downgrade() -> None:
    op.drop_index(op.f("ix_chat_messages_sessionId"), table_name="chat_messages")
    op.drop_table("chat_messages")
    op.drop_index(op.f("ix_chat_sessions_userId"), table_name="chat_sessions")
    op.drop_table("chat_sessions")
