export function getTimeRemaining(endTime: number): string {
    const currentTime = Date.now();
    const remainingTime = endTime - currentTime;

    if (remainingTime <= 0) {
        return "Expired";
    }

    const seconds = Math.floor(remainingTime / 1000) % 60;
    const minutes = Math.floor(remainingTime / (1000 * 60)) % 60;
    const hours = Math.floor(remainingTime / (1000 * 60 * 60));

    let timeString = "";
    if (hours > 0) {
        timeString += `${hours}h `;
    }
    if (minutes > 0 || hours > 0) {
        timeString += `${minutes}m `;
    }
    timeString += `${seconds}s`;

    return timeString.trim();
}
