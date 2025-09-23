export interface Pet {
  image: string;
  petName: string;
  hunger: number;
  happy: number;
  level: number;
  currentExp: number;
  styleID: string;
}


export interface ApiResponse<T> {
  success: boolean;
  message: string;
  data?: T;
}
