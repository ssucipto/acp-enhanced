// IG-21 true-negative: static safe command
const { execFile } = require("child_process");
execFile("ls", ["-la"], () => {});
