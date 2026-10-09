<?php

declare(strict_types=1);

namespace Summer\Http;

use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Http\Server\MiddlewareInterface;
use Psr\Http\Server\RequestHandlerInterface;

/**
 * "And summer's lease hath all too short a date": a request that spends more
 * than one summer in the handler is turned away with a 504.
 */
final class SummerLease implements MiddlewareInterface
{
    private const LEASE = 3.0;

    public function process(
        ServerRequestInterface $request,
        RequestHandlerInterface $next,
    ): ResponseInterface {
        $started = microtime(true);
        $response = $next->handle($request);
        $spent = microtime(true) - $started;

        return $spent > self::LEASE
            ? $response->withStatus(504, 'the lease of summer is over')
            : $response->withHeader('x-summer-lease', (string) $spent);
    }
}
