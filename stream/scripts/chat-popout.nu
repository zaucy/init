def chat-popout [] {
	let program_files = if 'ProgramFiles' in $env { $env.ProgramFiles } else { $env.PROGRAMFILES }
	let chrome = $program_files + "\\Google\\Chrome\\Application\\chrome.exe"
	^$chrome --profile-directory=Default --app="https://www.twitch.tv/popout/zauucy/chat?popout="
}

