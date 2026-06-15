// IG-21 true-positive: dynamic exec
const cmd = `rm -rf ${process.env.TARGET}`;
require("child_process").exec(cmd);
