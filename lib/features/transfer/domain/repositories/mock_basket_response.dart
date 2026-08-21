/// Mock response untuk endpoint getBasketByCode
/// Dipakai untuk testing repository/usecase tanpa perlu hit API sungguhan.
const Map<String, dynamic> mockBasketResponseJson = {
  "status": true,
  "message": "Berhasil mengambil data basket",
  "data": {
    "id": 1,
    "basket_code": "A0001",
    "grades": [
      {"id": 1, "grade": "A", "quantity": 1000, "received_quantity": 1000},
      {"id": 2, "grade": "A+", "quantity": 250, "received_quantity": 1000},
      {"id": 3, "grade": "B", "quantity": 250, "received_quantity": 1000},
      {"id": 4, "grade": "C", "quantity": 250, "received_quantity": 1000},
    ],
    "transfer": {
      "id": 1,
      "transfer_code": "15082024TE0002",
      "transfer_date": "2024-01-15",
      "branch": {"id": 1, "name": "Jabung"},
    },
  },
};

/// Contoh mock untuk kasus basket tidak ditemukan (404 / error)
const Map<String, dynamic> mockBasketNotFoundResponseJson = {
  "status": false,
  "message": "Basket dengan kode tersebut tidak ditemukan",
  "data": null,
};

/// Mock response untuk endpoint getReceivedBaskets (list, bukan satu basket)
/// Dipakai untuk testing header rekap + list di ScannedBasketsList tanpa
/// perlu hit API sungguhan.
const Map<String, dynamic> mockReceivedBasketsResponseJson = {
  "status": true,
  "message": "Berhasil mengambil data basket yang diterima",
  "data": [
    {
      "id": 1,
      "basket_code": "A0001",
      "grades": [
        {"id": 1, "grade": "A", "quantity": 1000, "received_quantity": 1000},
      ],
      "transfer": {
        "id": 1,
        "transfer_code": "15082024TE0002",
        "transfer_date": "2024-01-15",
        "production_date": "2024-01-14",
        "farm": "Jabung",
      },
    },
    {
      "id": 2,
      "basket_code": "A0002",
      "grades": [
        {"id": 5, "grade": "A", "quantity": 800, "received_quantity": 780},
        {"id": 6, "grade": "B", "quantity": 200, "received_quantity": 200},
      ],
      "transfer": {
        "id": 1,
        "transfer_code": "15082024TE0002",
        "transfer_date": "2024-01-15",
        "production_date": "2024-01-14",
        "farm": "Jabung",
      },
    },
    {
      "id": 3,
      "basket_code": "B0015",
      "grades": [
        {"id": 7, "grade": "A", "quantity": 500, "received_quantity": 500},
      ],
      "transfer": {
        "id": 2,
        "transfer_code": "16082024TE0009",
        "transfer_date": "2024-01-16",
        "production_date": "2024-01-15",
        "farm": "Purwosari",
      },
    },
  ],
};

/// Contoh mock untuk kasus basket sudah pernah diterima sebelumnya
/// (berguna untuk testing validasi duplicate scan)
const Map<String, dynamic> mockBasketAlreadyReceivedResponseJson = {
  "status": false,
  "message": "Basket ini sudah pernah diterima sebelumnya",
  "data": {
    "id": 1,
    "basket_code": "A0001",
    "grades": [
      {"id": 1, "grade": "A", "quantity": 1000, "received_quantity": 1000},
    ],
    "transfer": {
      "id": 1,
      "transfer_code": "15082024TE0002",
      "transfer_date": "2024-01-15",
      "branch": {"id": 1, "name": "Jabung"},
    },
  },
};

/// Mock response untuk endpoint getAllHistoryHeaderReceive (list header riwayat transfer)
const Map<String, dynamic> mockAllHistoryHeaderReceiveResponseJson = {
  "status": true,
  "message": "Berhasil mengambil data riwayat transfer",
  "data": [
    {
      "id": 1,
      "transfer_code": "15082024TE0001",
      "transfer_date": "2024-01-15",
      "production_date": "2024-01-14",
      "farm": "Jabung",
      "sent_basket_count": 20,
      "received_basket_count": 20,
    },
    {
      "id": 2,
      "transfer_code": "16082024TE0009",
      "transfer_date": "2024-01-16",
      "production_date": "2024-01-15",
      "farm": "Purwosari",
      "sent_basket_count": 20,
      "received_basket_count": 20,
    },
    {
      "id": 3,
      "transfer_code": "17082024TE0003",
      "transfer_date": "2024-01-17",
      "production_date": "2024-01-16",
      "farm": "Jabung",
      "sent_basket_count": 20,
      "received_basket_count": 20,
    },
  ],
};

/// Mock response untuk endpoint getHistoryDetailReceive (detail satu transfer)
const Map<String, dynamic> mockHistoryDetailReceiveResponseJson = {
  "status": true,
  "message": "Berhasil mengambil detail riwayat transfer",
  "data": {
    "id": 1,
    "transfer_code": "15082024TE0001",
    "transfer_date": "2024-01-15",
    "basket_send_count": 3,
    "basket_receive_count": 2,
    "branch": {"id": 1, "name": "Jabung"},
    "baskets": [
      {
        "id": 1,
        "basket_code": "A0001",
        "received_at": "2024-01-15T08:30:00",
        "grades": [
          {"id": 1, "grade": "A", "quantity": 1000, "received_quantity": 1000},
          {"id": 2, "grade": "A+", "quantity": 250, "received_quantity": 240},
        ],
      },
      {
        "id": 2,
        "basket_code": "A0002",
        "received_at": "2024-01-15T09:00:00",
        "grades": [
          {"id": 3, "grade": "B", "quantity": 800, "received_quantity": 780},
        ],
      },
      {
        "id": 3,
        "basket_code": "A0003",
        "received_at": null,
        "grades": [
          {"id": 4, "grade": "C", "quantity": 500, "received_quantity": null},
        ],
      },
      {
        "id": 1,
        "basket_code": "A0001",
        "received_at": "2024-01-15T08:30:00",
        "grades": [
          {"id": 1, "grade": "A", "quantity": 1000, "received_quantity": 1000},
          {"id": 2, "grade": "A+", "quantity": 250, "received_quantity": 240},
        ],
      },
      {
        "id": 2,
        "basket_code": "A0002",
        "received_at": "2024-01-15T09:00:00",
        "grades": [
          {"id": 3, "grade": "B", "quantity": 800, "received_quantity": 780},
        ],
      },
      {
        "id": 3,
        "basket_code": "A0003",
        "received_at": null,
        "grades": [
          {"id": 4, "grade": "C", "quantity": 500, "received_quantity": null},
        ],
      },
      {
        "id": 1,
        "basket_code": "A0001",
        "received_at": "2024-01-15T08:30:00",
        "grades": [
          {"id": 1, "grade": "A", "quantity": 1000, "received_quantity": 1000},
          {"id": 2, "grade": "A+", "quantity": 250, "received_quantity": 240},
        ],
      },
      {
        "id": 2,
        "basket_code": "A0002",
        "received_at": "2024-01-15T09:00:00",
        "grades": [
          {"id": 3, "grade": "B", "quantity": 800, "received_quantity": 780},
        ],
      },
      {
        "id": 3,
        "basket_code": "A0003",
        "received_at": null,
        "grades": [
          {"id": 4, "grade": "C", "quantity": 500, "received_quantity": null},
        ],
      },
    ],
  },
};

/// Contoh mock untuk kasus detail riwayat tidak ditemukan
const Map<String, dynamic> mockHistoryDetailNotFoundResponseJson = {
  "status": false,
  "message": "Riwayat tidak ditemukan",
  "data": null,
};
