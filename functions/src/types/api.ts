export interface Pet {
  image: string;
  name: string;
  hunger: number;
  happy: number;
  level: number;
  currentExp: number;
  styleID: string;
}

export interface Item {
  icon: string;
  category: number;
  name: string;
  hunger: number;
  happy: number;
  count: number;
  price: number;
  itemText: string;
}


export interface ApiResponse<T> {
  success: boolean;
  message: string;
  data?: T;
}
