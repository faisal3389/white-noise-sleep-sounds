export interface Sound {
  id: string;
  title: string;
  category: string;
  description: string;
  imageUrl: string;
  duration?: string;
  frequency?: string;
  tags: string[];
}

export interface Mix {
  id: string;
  title: string;
  description: string;
  imageUrls: string[];
  isActive?: boolean;
  sounds: string[];
}

export type Category = 'All' | 'Nature' | 'Rain' | 'ASMR' | 'Urban' | 'Focus';
