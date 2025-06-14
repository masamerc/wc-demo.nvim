BIN_NAME="server"

.PHONY: rebuild
rebuild:
	cd rpc && go build -o ./bin/$(BIN_NAME)
