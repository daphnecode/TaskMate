import * as functions from "firebase-functions/v2/https";
import {db} from "../firebase.js";

export const readPets = functions.onRequest(async (req, res) => {
  try {
    // 1. 인증
    const idToken = req.headers.authorization?.split("Bearer ")[1];
    if (!idToken) {
      res.status(401).json({ success: false, message: "Unauthorized" });
      return;
    }

    // 2. userID (params에서 가져오기)
    const pathParts = req.path.split("/");
    const userId = pathParts[pathParts.length - 1]; // /pet/read/{userID}
    if (!userId) {
      res.status(400).json({ success: false, message: "Missing userID" });
      return;
    }

    // 3. Firestore에서 펫 목록 조회
    const petsRef = db.collection("Users").doc(userId).collection("Pets");
    const snapshot = await petsRef.get();

    const pets = snapshot.docs.map(doc => ({
      petName: doc.data().petName,
      level: doc.data().level,
    }));

    // 4. 응답
    res.status(200).json({
      success: true,
      message: "pet read complete",
      data: pets,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, message: "Internal Server Error" });
  }
});