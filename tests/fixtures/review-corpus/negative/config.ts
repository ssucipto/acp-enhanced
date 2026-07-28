const origin = "https://example.com";
const apiUrl = process.env.API_URL;
const callbackUrl = `/callback?code=${code}`;
res.status(500).json({ data: { message: error.message } });
const digest = createHash('sha256').update(payload).digest('hex');
