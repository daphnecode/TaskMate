import { onSchedule } from "firebase-functions/v2/scheduler";
import * as admin from "firebase-admin";
admin.initializeApp();

export const pushNotifications = onSchedule(
  {
    schedule: "0 8,12,18 * * *",
    timeZone: "Asia/Seoul",
    region: "asia-northeast3",
  },
  async () => {
    await admin.messaging().send({
      notification: { title: "🐾 하루 일정 알림", body: "오늘의 할 일을 확인해보세요!" },
      topic: "dailyReminder",
    });
    console.log("✅ Scheduled notification sent successfully");
  }
);
