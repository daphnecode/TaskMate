import express from "express";
import { getAuth } from "firebase-admin/auth";
import {db} from "../firebase.js";
import { Item } from "../types/api.js";

export async function verifyToken(req: express.Request) {
  const h = req.headers.authorization || "";
  if (!h.startsWith("Bearer ")) throw new Error("No ID token provided");
  const token = h.substring("Bearer ".length);
  return getAuth().verifyIdToken(token);
}
export function refInventory(uid: string) {
  return db.collection("Users").doc(uid).collection("items") as FirebaseFirestore.CollectionReference<Item>;
}
export function refShop(category: number) {
  return db.collection("aLLitems").where("category", "==", Number(category)).get();
}
export function refShopItem(itemName: string) {
  return db.collection("aLLitems").doc(itemName);
}
export function refItem(uid: string, itemName: string) {
  return db.collection("Users").doc(uid).collection("items").doc(itemName);
}
export function refUser(uid: string) {
  return db.collection("Users").doc(uid);
}
export function refPets(uid: string) {
  return db.collection("Users").doc(uid).collection("pets");
}
export function refStats(uid: string) {
  return db.collection("Users").doc(uid).collection("stats").doc("summary");
}
