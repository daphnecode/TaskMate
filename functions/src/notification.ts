import { onSchedule } from "firebase-functions/v2/scheduler";
import * as admin from "firebase-admin";
import { db } from "./firebase"; // ✅ 당신이 만든 firebase.ts 사용

export const pushNotifications = onSchedule(
  {
    // schedule: "0 8,12,18 * * *",
    schedule: "0 */1 * * *",
    timeZone: "Asia/Seoul",
    region: "asia-northeast3",
  },
  async () => {
    try {
      const snapshot = await db
        .collection("Users")
        .where("setting.push", "==", true)
        .get();

      const tokens: string[] = [];
      snapshot.forEach((doc) => {
        const data = doc.data();
        if (data.fcmToken) tokens.push(data.fcmToken);
      });

      if (tokens.length === 0) {
        console.log("❌ No valid tokens found.");
        return;
      }

      const message = {
        notification: {
          title: "🐾 하루 일정 알림",
          body: "오늘의 할 일을 확인해보세요!",
        },
      };

      const chunkSize = 500;
      for (let i = 0; i < tokens.length; i += chunkSize) {
        const chunk = tokens.slice(i, i + chunkSize);
        const response = await admin.messaging().sendEachForMulticast({
          ...message,
          tokens: chunk,
        });
        console.log(
          `📩 Sent batch ${i / chunkSize + 1}: ${response.successCount} success, ${response.failureCount} failed`
        );
      }

      console.log("✅ All notifications sent successfully");
    } catch (error) {
      console.error("🔥 Error sending notifications:", error);
    }
  }
);
