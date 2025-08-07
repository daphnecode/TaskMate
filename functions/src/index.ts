import {onDocumentWritten} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";

admin.initializeApp();
const db = admin.firestore();

export const onTaskSubmitted = onDocumentWritten(
  "Users/{userId}/log/{logId}",
  async (event) => {
    const userId = event.params.userId;
    const newLog = event.data?.after.data();
    if (!newLog) return;

    const statsRef = db
      .collection("Users")
      .doc(userId)
      .collection("stats")
      .doc("summary");

    const statsDoc = await statsRef.get();
    let totalCompleted = 0;
    let streakDays = 0;
    let lastUpdated: FirebaseFirestore.Timestamp | null = null;

    if (statsDoc.exists) {
      const data = statsDoc.data();
      totalCompleted = data?.totalCompleted || 0;
      streakDays = data?.streakDays || 0;
      lastUpdated = data?.lastUpdated || null;
    }

    // 수정: 필드명 맞춤
    const completedCount = newLog.completedCount || 0;

    const today = new Date();
    const todayStr = today.toISOString().split("T")[0];
    let newStreak = streakDays;

    if (lastUpdated) {
      const lastDate = new Date(lastUpdated.toDate());
      const lastStr = lastDate.toISOString().split("T")[0];

      if (lastStr !== todayStr) {
        const diff =
          (today.getTime() - lastDate.getTime()) /
          (1000 * 60 * 60 * 24);
        newStreak = diff === 1 ? streakDays + 1 : 1;
      }
    } else {
      newStreak = 1;
    }

    await statsRef.set(
      {
        totalCompleted: totalCompleted + completedCount,
        streakDays: newStreak,
        lastUpdated: admin.firestore.Timestamp.now(),
      },
      {merge: true}
    );

    console.log(
      `Stats updated for user ${userId}: +${completedCount} tasks, streak ${newStreak}`
    );
  }
);
