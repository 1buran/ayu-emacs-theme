// Package summer answers with a sonnet, one line per request.
package summer

import (
	"context"
	"fmt"
	"net/http"
	"time"
)

// lease is how long a request may keep the summer for itself.
const lease = 3 * time.Second

// Sonnet serves "Shall I compare thee to a summer's day?" line by line.
type Sonnet struct {
	Lines []string
}

// ServeHTTP returns one line; "and summer's lease hath all too short a date",
// so a request that holds on to the sonnet is turned away.
func (s *Sonnet) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	ctx, cancel := context.WithTimeout(r.Context(), lease)
	defer cancel()

	select {
	case <-ctx.Done():
		http.Error(w, "the lease of summer is over", http.StatusGatewayTimeout)
	case <-time.After(lease / 3):
		fmt.Fprintln(w, s.Lines[len(r.URL.Query().Get("line"))%len(s.Lines)])
	}
}
