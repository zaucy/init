def chat-popout [] {
	let chrome = $env.ProgramFiles + "\\Google\\Chrome\\Application\\chrome.exe"
	^$chrome --profile-directory=Default --app="https://www.twitch.tv/popout/zauucy/chat?popout="
}

