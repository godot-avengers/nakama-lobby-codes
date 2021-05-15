package main

import (
	"context"
	"database/sql"

	"github.com/heroiclabs/nakama-common/runtime"
)

// LobbyCodeGetMatchID returns the matchID of a match associated with a lobby code
func LobbyCodeGetMatchID(ctx context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule, payload string) (string, error) {

	logger.Warn("LobbyCodeGetMatchID is not fully implemented and is likely to act unpredictably!")

	// WARNING: LOBBYCODE SHOULD COME FROM PAYLOAD!
	lobbyCode := "123"

	matches, err := nk.MatchList(ctx, 1, false, lobbyCode, nil, nil, "") // WARNING: DOES NOT PROPERLY QUERY LABEL
	if err != nil {
		logger.Error("Failed to list matches when looking up lobby code: %v", err)
		return "", err
	}

	if len(matches) > 0 {
		return matches[0].MatchId, nil
	}

	// Since a match could not be found, create a new one
	matchID, err := nk.MatchCreate(ctx, "", map[string]interface{}{})
	if err != nil {
		logger.Error("Failed to create match with lobby code: %v", err)
		return "", err
	}

	// WARNING: LOBBYCODE LABEL SHOULD BE SET HERE

	logger.Info("Match created from lobby code: %v", lobbyCode)

	return matchID, nil
}

// InitModule is the method called by Nakama to intialize the plugin
func InitModule(ctx context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule, initializer runtime.Initializer) error {
	logger.Info("Intializing lobby code plugin...")

	// Register RPC function
	if err := initializer.RegisterRpc("LobbyCodeGetMatchID", LobbyCodeGetMatchID); err != nil {
		logger.Error("Unable to register: %v", err)
		return err
	}

	logger.Info("Successfully intialized lobby code plugin!")
	return nil
}

func main() {}
