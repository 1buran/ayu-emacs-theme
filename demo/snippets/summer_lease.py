"""Shall I compare thee to a summer's day? -- a lease for every request."""

from __future__ import annotations

import asyncio
from dataclasses import dataclass
from typing import Awaitable, Callable

Handler = Callable[[dict], Awaitable[dict]]


@dataclass(frozen=True, slots=True)
class SummerLease:
    """Turns away the requests that outlive the lease of a summer."""

    handler: Handler
    lease: float = 3.0

    async def __call__(self, request: dict) -> dict:
        # "And summer's lease hath all too short a date": rather than let the
        # handler keep it, answer with a 504 of our own.
        try:
            return await asyncio.wait_for(self.handler(request), self.lease)
        except TimeoutError:
            return {"status": 504, "error": "the lease of summer is over"}
