strHookURL = 'https://hooks.slack.com/services/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';
strText = 'Test2';
strTarget = '#behavior';
strUsername = 'webhookbot';
strIconEmoji = ':tada:';

[strHTTPOutput, sHTTPExtra] = SendSlackNotification(strHookURL, strText, strTarget, strUsername, [], strIconEmoji, []);