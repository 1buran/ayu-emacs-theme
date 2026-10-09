'use strict';

/**
 * "Shall I compare thee to a summer's day?": a lease for every request, so
 * that no handler keeps the summer for itself.
 */
export function summerLease({ lease = 3000, log = console.warn } = {}) {
  return function leaseOfSummer(req, res, next) {
    const started = Date.now();
    const expired = setTimeout(() => {
      log(`${req.method} ${req.path} outlived the lease of summer`);
      res.status(504).json({ error: 'the lease of summer is over' });
    }, lease);

    res.on('finish', () => {
      clearTimeout(expired);
      log(`${req.method} ${req.path} took ${Date.now() - started}ms`);
    });

    next();
  };
}
