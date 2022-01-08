defmodule BorshEx.Metadata.Creator do
  use BorshEx.Schema
  defstruct address: nil, verified: nil, share: nil

  borsh_schema do
    field :address, {"array", {"u8", 32}}
    field :verified, "boolean"
    field :share, "u8"
  end
end

defmodule BorshEx.Metadata.Data do
  use BorshEx.Schema
  defstruct name: nil, symbol: nil, uri: nil, seller_fee_basis_points: nil, creators: nil

  borsh_schema do
    field :name, "string"
    field :symbol, "string"
    field :uri, "string"
    field :seller_fee_basis_points, "u16"
    field :creators, {"option", {"array", BorshEx.Metadata.Creator}}
  end
end

defmodule BorshEx.Metadata do
  use BorshEx.Schema

  defstruct key: nil,
            update_authority: nil,
            mint: nil,
            data: nil,
            primary_sale_happened: nil,
            is_mutable: nil,
            edition_nonce: nil

  @keys [
    "Uninitialized",
    "EditionV1",
    "MasterEditionV1",
    "ReservationListV1",
    "MetadataV1",
    "ReservationListV2",
    "MasterEditionV2",
    "EditionMarker"
  ]

  borsh_schema do
    field :key, {"enum", @keys}
    field :update_authority, {"array", {"u8", 32}}
    field :mint, {"array", {"u8", 32}}
    field :data, BorshEx.Metadata.Data
    field :primary_sale_happened, "boolean"
    field :is_mutable, "boolean"
    field :edition_nonce, {"option", "u8"}
  end

  def bitstring do
    <<4, 103, 178, 33, 86, 213, 234, 135, 181, 67, 50, 172, 200, 75, 170, 90, 51, 121, 205, 197,
      58, 32, 37, 249, 246, 220, 123, 81, 9, 164, 84, 25, 50, 134, 73, 3, 252, 124, 233, 150, 137,
      45, 156, 252, 11, 24, 83, 175, 26, 35, 209, 159, 234, 219, 1, 19, 170, 142, 82, 248, 53,
      163, 227, 218, 70, 32, 0, 0, 0, 71, 114, 101, 97, 116, 32, 109, 111, 110, 107, 101, 121, 32,
      116, 101, 115, 116, 32, 35, 53, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 200, 0, 0, 0, 104, 116, 116, 112, 115, 58, 47, 47, 97, 114, 119, 101, 97,
      118, 101, 46, 110, 101, 116, 47, 111, 103, 99, 81, 57, 79, 68, 89, 113, 48, 70, 84, 89, 79,
      50, 56, 68, 90, 69, 105, 106, 120, 67, 57, 65, 98, 109, 120, 49, 71, 53, 69, 52, 103, 76,
      52, 55, 88, 98, 71, 122, 52, 119, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 244, 1, 1, 2, 0,
      0, 0, 190, 33, 0, 57, 29, 25, 109, 67, 90, 230, 46, 171, 101, 130, 3, 200, 220, 238, 234,
      72, 188, 223, 51, 50, 89, 144, 10, 196, 170, 201, 2, 233, 1, 0, 183, 178, 9, 212, 189, 225,
      94, 205, 17, 177, 80, 139, 70, 144, 164, 94, 222, 54, 123, 79, 47, 113, 27, 203, 76, 227,
      219, 241, 74, 251, 138, 121, 0, 100, 1, 1, 1, 254>>
  end

  def example do
    %BorshEx.Metadata{
      data: %BorshEx.Metadata.Data{
        creators: [
          %BorshEx.Metadata.Creator{
            address: [
              190,
              33,
              0,
              57,
              29,
              25,
              109,
              67,
              90,
              230,
              46,
              171,
              101,
              130,
              3,
              200,
              220,
              238,
              234,
              72,
              188,
              223,
              51,
              50,
              89,
              144,
              10,
              196,
              170,
              201,
              2,
              233
            ],
            share: 0,
            verified: true
          },
          %BorshEx.Metadata.Creator{
            address: [
              183,
              178,
              9,
              212,
              189,
              225,
              94,
              205,
              17,
              177,
              80,
              139,
              70,
              144,
              164,
              94,
              222,
              54,
              123,
              79,
              47,
              113,
              27,
              203,
              76,
              227,
              219,
              241,
              74,
              251,
              138,
              121
            ],
            share: 100,
            verified: false
          }
        ],
        name:
          <<71, 114, 101, 97, 116, 32, 109, 111, 110, 107, 101, 121, 32, 116, 101, 115, 116, 32,
            35, 53, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0>>,
        seller_fee_basis_points: 500,
        symbol: <<0, 0, 0, 0, 0, 0, 0, 0, 0, 0>>,
        uri:
          <<104, 116, 116, 112, 115, 58, 47, 47, 97, 114, 119, 101, 97, 118, 101, 46, 110, 101,
            116, 47, 111, 103, 99, 81, 57, 79, 68, 89, 113, 48, 70, 84, 89, 79, 50, 56, 68, 90,
            69, 105, 106, 120, 67, 57, 65, 98, 109, 120, 49, 71, 53, 69, 52, 103, 76, 52, 55, 88,
            98, 71, 122, 52, 119, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0>>
      },
      edition_nonce: 254,
      is_mutable: true,
      key: "MetadataV1",
      mint: [
        134,
        73,
        3,
        252,
        124,
        233,
        150,
        137,
        45,
        156,
        252,
        11,
        24,
        83,
        175,
        26,
        35,
        209,
        159,
        234,
        219,
        1,
        19,
        170,
        142,
        82,
        248,
        53,
        163,
        227,
        218,
        70
      ],
      primary_sale_happened: true,
      update_authority: [
        103,
        178,
        33,
        86,
        213,
        234,
        135,
        181,
        67,
        50,
        172,
        200,
        75,
        170,
        90,
        51,
        121,
        205,
        197,
        58,
        32,
        37,
        249,
        246,
        220,
        123,
        81,
        9,
        164,
        84,
        25,
        50
      ]
    }
  end
end
