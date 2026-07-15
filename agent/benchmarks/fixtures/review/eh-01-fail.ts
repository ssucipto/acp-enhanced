// Phase 1 fixture: EH-01 fail — async without try/catch
export async function fetchData(url: string) {
  const res = await fetch(url);
  return res.json();
}
