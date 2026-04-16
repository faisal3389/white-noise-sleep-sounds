import { Sound, Mix } from './types';

export const SOUNDS: Sound[] = [
  {
    id: 'rain-on-lake',
    title: 'Rain on Lake',
    category: 'Daily Refresh',
    description: 'Gentle ripples and soft patter',
    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCYbs7SG-LncHyuq9368ehI7YDErPrSoBCpRt31Z3U2i4koOtLd_gytQc1IR-Tp6Od2aLzEvtNw4n_57zNv8F5ZPoT1bfG_Xk8BkHgmN84zwzuokzljGq5kLVOGjcw3oD_Wtr3aBGka2Z2Rdk9i3TSNeERHTcoxQ6hag7ArJq9bzaEkZEaLY6rI6Pq52aAXYd_ux-kt4UYZXakeBc3ezHweozNeJ9yKxdcVxJMKHmAsUcdS2AC-Nx3TEjQ1AIS3nXJN49a3g_P4lCI',
    duration: '8:00',
    tags: ['Nature', 'Rain']
  },
  {
    id: 'distant-storm',
    title: 'Distant Storm',
    category: 'Nature',
    description: 'Deep, low frequency thrum',
    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAciRflgTPE8oOn9Muq6arygpAJko1QgxFzBe6PHqB_0sNvaxuPKpzZUWeDN74ezH4uLhNUNexPwVFjCiLCPvTIj3-2SSPWl8ED18uQj7E7tPfFwLrzR9JLsaqs_4JB4wQufFdpOBGbJ7Zy52VJg-cIb30jkGa-f_kRHtgdvy1Ut_SMQB7fhBbPyrKEQk5M_TjtIzr0SZXZiLqVY_-NmlekQW8XU5mQ511fmSZPaWSfG9DD7MMjNc1SC2rL43qweyeikXqTAPYj7lg',
    duration: '12:00',
    tags: ['Nature', 'Storm']
  },
  {
    id: 'wind-chimes',
    title: 'Wind Chimes',
    category: 'Nature',
    description: 'Soft metallic resonance',
    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDuz5HANC4JE0jQrF9_mi4RcMjmlvWlG_pWseQLvy3rMwyREBB_RIPvTRyjXVC8wWZs5fPvFK1rGVhH-NBSeE0aEkdyHF2JvQMK2UpjbDwPEiDYrXY7Scp8o6s1KjKrNN56cpRnxpeLu5NoU-uKe94HKso4EiyKoBJB6eYtbWqFBaN67znm73YT6YX86_PzIXFfO13lvRwDO8TnXTG0tbCrm9CDvO3zQa86sIcRIDPvoP8qBxKlJ8fHvsBLfrTrgZ3VNFoa0OMrCPM',
    duration: '15:00',
    tags: ['Nature', 'Zen']
  },
  {
    id: 'winter-breath',
    title: 'Winter Breath',
    category: 'Nature',
    description: 'Crisp, airy white noise',
    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBJqPMnHDO1hG07roEhC0X0pksp_VshUtI1pZKHma_uIaJO8TndWMaJLkyLqP3zkxYi-v_94_RoPTXJUBQbdjlxRxdX6OlIDxlna4OjLunG7TT9hD4XkcyT4_JJH8n38AoWlw5HYEVsHWFWd0td6nBwp2LgW3glLF83hIs7a0gRIUYKqzeZWsvMzMKMpCRF3hS1OBnjM94qDX2zninErK_LMXb4gCf8ljhK2HWVazDFi0hv16arJ-Ur03kiXuOFl-lv1MNit2p9HRU',
    duration: '10:00',
    tags: ['Nature', 'Winter']
  },
  {
    id: 'amazon-jungle',
    title: 'Amazon Jungle',
    category: 'Tropical Nature',
    description: 'Dense tropical rainforest canopy',
    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBnc35p-Lr7oE6rl0DYV_xvMbniaa1C5IAVwiZ6kS5U0uMXgUYvtDGtYGZHdITtaRsqeIojjaF8OJvMwuNKERCUtkTpAZTv-SJa4b8MoGuoX4jjx4XBUc39F2jfInVM2Elmt34cLQjyAj8mF7g-1-noUs_uwbZ_srcQ0qynqrpOytsZ7TWo7CkbKqoWGAd-c0FTvZKn7bOG6RjAmy6en5NFsNERqyGrlJDvKoZWv-yhvI_OQxaRSTcjc7Zm01sV3s5rlRbO9tEY50I',
    duration: '8:00',
    tags: ['Nature', 'Tropical']
  },
  {
    id: 'beach-waves',
    title: 'Beach Waves',
    category: 'Ocean Breeze',
    description: 'Crystal clear turquoise ocean waves',
    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCwujFUspxeCHF0kZBNWbV59aZ28fJ8bzBQQTDNNlQLJqX82d0DM2XuJLDUHXwryoxvAdRBe2ywBh2yCEhwkoAS9_dLYObYIClJMjqTR59QAeu4wSUbyW9GaQdUwDqFJEsmofgO20UqhQ8M0bj3MA12SUCFCKFWwBcw2moU0-AbW-FIOK2MdagPYTNWGnNFG4Pl-OP-vdz6DIv0w8_Ou-egaLyqr0uMfekpo-WX_SsDZ_PTSYGLkQ3mjG7PG4iE8KnkBM5cTC10L-s',
    duration: 'Infinite',
    tags: ['Nature', 'Ocean']
  },
  {
    id: 'camp-fire',
    title: 'Camp Fire',
    category: 'Evening Cozy',
    description: 'Crackling campfire with glowing embers',
    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAjF-S8FBHFJ56H-HM2g0qL1NbZm6pecwD_ZW6WVjlVLwhTwO_OwKSwRwSDKhxCewn4Yqjf2ck4RTwcrZDZMaQDZREUNfTJ-9g3VRRaYeJGCsmPsD0EHm_fdQ_oGAqLgAdKM5POaMx2XmC6Fnl_GnpDsSJKG3WB2ReTEuJNohStZd8UmChuusykXZ1NIMKVyb3tT68a3nEK4CWCBbfyrrmBP0u8BSKS41wooUOkfXF6tu4xwhOtt8gVKb3nxXdgpumXFkbahzNaelY',
    duration: 'Warm Texture',
    tags: ['Nature', 'Fire']
  },
  {
    id: 'midnight-storm',
    title: 'Midnight Storm',
    category: 'Powerful Rain',
    description: 'Dramatic dark storm clouds and lightning',
    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDdPVPNW8GSLzyPGLEC5yxmaGnnN9XxkTlMfHzAMjF-WXtL-pcyYNGNDM_bB3ZGQHVQJRZbZPnelosKC7qJhBUUf83gtq39haYtP4-wwcB2OB1fRfVDiNKN5FTcu21VDiNGzHJ8XIyr_oXxQwW5dZ-AAo7kLGcD_xeGkomjH6r47-mT4-IekHFLh7t25bjk_xN9MJtu9YwfT4MCOeM3jZVBwsgu5vWZcqSewFTXDBtF0PjHluUSjhbvBwd6OyU4jkgxdMuD6RD3Pl0',
    duration: '45:00',
    tags: ['Nature', 'Rain', 'Storm']
  },
  {
    id: 'zen-garden',
    title: 'Zen Garden',
    category: 'Mindfulness',
    description: 'Serene japanese zen garden',
    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCTSOtCVeWuGcEW3qqahkLmJDD7HpPq4pIPFIXbEk4JE3ZhgP7Uty25YnI-1nLZMbrSUjLB1tGC4Nt_LoEtwLjkZ8-dyEYUw_gDd0CruiC-4ddGGJ5sKbIykV_TI9QGB40ChhM5iyF1JglCMCMOfy34uT_bs6cvgCAtctKguTb_7qzMtrThEq7RCUMREh_bgP9YESjfOpDOJVh_O5sR1wi5K6ButkaEi4Zk8p1CVg4dkN7_a8KKT5EN9axBqdHHzQcZ8DZ0d8u1uw8',
    duration: 'Soft Bamboo',
    tags: ['Nature', 'Zen']
  },
  {
    id: 'winter-path',
    title: 'Winter Path',
    category: 'Arctic Calm',
    description: 'Tranquil snowy forest',
    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCjyp0XPDNrac_g2moo7eiLhnuy04aXToGY3XikDnhTdcqgnwNPZicjHgG_Deu1dF8xqOLccqJ4acDAmMYsceWMWYzeYP1YXg2-s_pZU9KJzpBxV7Qxk59qRstymeklkfGVGnyB4QXOMarx18X_2NKsf8hSqF0PhdnWrRoy1lq64FtGpQW9dEAUiBs5G3aUXQjSjI8lB0Nz6o66TJ9uV1RV0cfbymGyGv4CbNvxGyAiiGj3CzXlp8hjTd0KYFikcXymVHZ6xAcJPAU',
    duration: 'Crunchy Steps',
    tags: ['Nature', 'Winter']
  }

];

export const MIXES: Mix[] = [
  {
    id: 'stormy-night',
    title: 'Stormy Night',
    description: 'Heavy Rain, Deep Thunder, Wind',
    isActive: true,
    imageUrls: [
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDnpC5Bz8BsjTuDWj0txlHil081pUWTP0irR-ZUoCQ0-HW7HcdqYWZJsuHSJu-lZdNr3o8LuWsvZ16XvFpg5fzDf7CBg36jBKo02g3I4acULZgXUivBF062laZbuEprpABtg9LE437PAk4RKMkiUOyYo0HP4a0wY70PSycrCp65kMXeUq8BoTQdlIB1_2qW5gDqqx5lH4JA1YyvSNb3MuXlFhqHTVhzLB53N-KwWpfVgDNB55qd3voM24rcGDN9F1cOGzvzj7mvx3c',
      'https://lh3.googleusercontent.com/aida-public/AB6AXuACYlmfoexDJqnwxN11_BBgWOVuMdsJvZre129MuggjeVmUiVW8PXlIDaaljhA3RKUiV13lurIK2vel-gpca-w2IOcUDssaphnXzPGna1OkkmkFJw-WJf1dSIA91glBK6Rb9Oot0g7ZxJwsFh2fEfznelH0pSMygncpwNQHN2U5QeYPwBHbKwEw8I8Josi4rTK5-roz1boihRsXK3f6sJAY5QEoSdrvXspz4cxbGqCnk0drIaarieAhY23l6q8aWnxOJxXKBijKc-A'
    ],
    sounds: ['rain-on-lake', 'midnight-storm']
  },
  {
    id: 'forest-stream',
    title: 'Forest Stream',
    description: 'Birds, Running Water, Rustling Leaves',
    imageUrls: [
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDl9lcgYHd_1OV4Lsc17J7qVhEw2d0enllB-ZjqMnteCW0GXAVKUyn2kkhjgFzaJ7JJWei0LHj3Bc70Sw6ZJFJyFVzy7M7qrl9M_DKjZhsojuYG2LvlKojVNII7kO10cfMnE3i4dql0zqVYAobLbxyVw9dwonX325Nx4KOXT69U3RgEkIbxV5XMQGeDovnUaSwGKk-xNZwlDmxb_R2D6n4Nogk5lX2KLHJiwmSZH4Qny9SuKm2ION2-ZcYAAof6paefTvx9Yst_tSc',
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBzozHbhidDvHjb7AKRLmNWHZzMI6215qKyc8J7tg9nMc3JByisbBLUqCeYfY_nwKRI3qlaoqNXlEU7PsOh8PUMtjD8gQfADmrRCf5EP1qfGJyYPAU_YkV2PspceIppBXeuUNf4-ATYzCwTGUrUc4bM9IOwTwTSkrCwVE8HBIKUNT0tNA-ZnEW3zdfXQ0lTKfZZhWCEg1h2ss1fg1RAbdxgxBlTpSLzr1XRvPXJb9CGIHNKpYGffgvfJd_VHpexdPo33yp3w1AMCKw'
    ],
    sounds: ['zen-garden']
  }
];
