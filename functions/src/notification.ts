import {onSchedule} from "firebase-functions/v2/scheduler";
import * as admin from "firebase-admin";
import {db} from "./firebase"; // ✅ 당신이 만든 firebase.ts 사용

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

      const androidTokens: string[] = [];
      const webTokens: string[] = [];

      for (const doc of snapshot.docs) {
        const tokenSnapshot = await db
          .collection(`Users/${doc.id}/fcmTokens`)
          .get();

        tokenSnapshot.forEach((tDoc) => {
          const tokenData = tDoc.data();
          const token = tDoc.id; // 문서 ID가 토큰
          if (tokenData.platform === "android") {
            androidTokens.push(token);
          } else if (tokenData.platform === "web") {
            webTokens.push(token);
          }
        });
      }


      const message = {
        notification: {
          title: "🐾 하루 일정 알림",
          body: "오늘의 할 일을 확인해보세요!",
        },
      };

      // Android 알림 전송
      for (let i = 0; i < androidTokens.length; i += 500) {
        const chunk = androidTokens.slice(i, i + 500);
        const res = await admin.messaging().sendEachForMulticast({
          ...message,
          tokens: chunk,
        });
        console.log(
          `📱 Android batch ${i / 500 + 1}: ${res.successCount} 
          success, ${res.failureCount} failed`
        );
      }

      // Web 알림 전송
      for (let i = 0; i < webTokens.length; i += 500) {
        const chunk = webTokens.slice(i, i + 500);
        const res = await admin.messaging().sendEachForMulticast({
          ...message,
          tokens: chunk,
        });
        console.log(
          `🌐 Web batch ${i / 500 + 1}: ${res.successCount} 
          success, ${res.failureCount} failed`
        );
      }

      console.log("✅ All notifications sent successfully");
    } catch (error) {
      console.error("🔥 Error sending notifications:", error);
    }
  }
);
