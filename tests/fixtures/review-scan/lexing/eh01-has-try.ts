export async function fetchThing(): Promise<void> {
  try {
    await Promise.resolve("retry");
  } catch (e) {
    console.error(e);
  }
}
