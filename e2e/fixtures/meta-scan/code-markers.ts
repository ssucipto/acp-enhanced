// TypeScript source file with ACP meta marker — test fixture for acp.meta-scan.test.sh

// @acp.meta.code
// topic: pen-pal-service
// implements: R10
// file: src/services/penPalService.ts
// @acp.meta.end

export function unlockPenPal(userId: string, lessonsCompleted: number): boolean {
  if (lessonsCompleted >= 5) {
    return true;
  }
  return false;
}
