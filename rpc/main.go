package main

import (
	"fmt"
	"log"
	"os"
	"strings"

	"github.com/neovim/go-client/nvim"
)

// function exposed to neovim via RPC
func Hello(v *nvim.Nvim, args []string) error {
	return v.WriteOut(fmt.Sprintf("Hello %s!!\n", strings.Join(args, " ")))
}

// another function for neovim
func WordCount(v *nvim.Nvim, args []string) error {
	if len(args) == 0 {
		return v.WriteOut("Usage: WordCount <text>\n")
	}

	text := args[0]

	// count words (split by whitespace and filter empty strings)
	words := strings.Fields(text)
	wordCount := len(words)

	// count characters (excluding spaces)
	charCount := len(strings.ReplaceAll(text, " ", ""))

	// count lines
	lineCount := strings.Count(text, "\n") + 1
	if text == "" {
		lineCount = 0
	}

	result := fmt.Sprintf(`
Lines: %d
Words: %d
Characters: %d
`, lineCount, wordCount, charCount)

	return v.WriteOut(result)
}

// binary entry point
func main() {
	// turn off timestamps in output.
	log.SetFlags(0)

	// direct writes by the application to stdout garble the rpc stream.
	// redirect the application's direct use of stdout to stderr.
	stdout := os.Stdout
	os.Stdout = os.Stderr

	// create a client connected to stdio. the
	// sconfigure the client to use tandard log package for logging.
	v, err := nvim.New(os.Stdin, stdout, stdout, log.Printf)
	if err != nil {
		log.Fatal(err)
	}

	// register functions with the client.
	v.RegisterHandler("hello", Hello)
	v.RegisterHandler("wc", WordCount)

	// run the RPC message loop.
	// the Serve function returns when nvim closes.
	if err := v.Serve(); err != nil {
		log.Fatal(err)
	}
}
