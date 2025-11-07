import express from "express";
import {verifyToken, refToken} from "./pet/refAPI";

const router = express.Router();

router.post("/:userId/token", async (req, res) => {
  try {
    const decoded = await verifyToken(req);
    const { token, platform } = req.body;
    const uid = decoded.uid;

    if (decoded.uid !== uid) {
      return res.status(403).json({success: false, message: "Forbidden"});
    }

    if (!token) {
      return res.status(400).json({
        success: false, message: "token is required",
      });
    }
    
    if (!platform) {
      return res.status(400).json({
        success: false, message: "platform is required",
      });
    }

    const tokenRef = refToken(uid, token);
    
    await tokenRef.set({
          'token': token,
          'platform': platform,
        }, {merge: true});

    return res.status(200).json({
      success: true,
      message: "token save complete",
    });
  } catch (e: any) {
    console.error(e);
    return res.status(500).json({
      success: false, message: e?.message || "Server error",
    });
  }
});

export default router;
