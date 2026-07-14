// Phase 1 fixture: EH-01 pass — async with try/catch
export async function fetchData(url: string): Promise<unknown> {
  try {
    const res = await fetch(url);
    return res.json();
  } catch (error) {
    console.error(error);
    throw error;
  }
}
