export async function fetchThing(): Promise<void> {
  const msg = "we should retry this later";
  await Promise.resolve(msg);
}
