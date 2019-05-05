// {### 一份区块详情格式}

```json
{
    "timestamp": "2018-06-07T04:21:42.500",
    "producer": "creazyracoon",
    "confirmed": 0,
    "previous": "000a9125abad882e6a7937f5e0d394ac8a2180d3ce6365d762f187047d402fcc",
    "transaction_mroot": "0ec26e7b29e8e26b6a823b50be28b9562161cf68da7aa5afa7a30c317b2c5ac3",
    "action_mroot": "33acf64ae2257fdf126816d4cf9741c33926f9c7672b72d5159ae7d0776291ee",
    "schedule_version": 44,
    "new_producers": null,
    "header_extensions": [],
    "producer_signature": "SIG_K1_KaCQofDV2PrpVvFPrMwsKSR91iw5nEG3qZR1vFBMrgNtKBSBMpSTLCn8mA2nAuUxM7G9my3CdeCwaeSJwcy81rekeejd7K",
    "transactions": [
      {
        "status": "executed",
        "cpu_usage_us": 577,
        "net_usage_words": 16,
        "trx": {
          "id": "da7adfcd313217bbf7e63c06cf00110ccfc00ed1bda188ba3542a4cbf859203a",
          "signatures": [
            "SIG_K1_KgBxkQ81TCi3CYGziCds3BiR2fQd7rFc9j2Z21LoUPwK4ut7GWt2315ioQbcutE9mPs8yQj2xYjQZ16Mj3SRhLMko63CiB"
          ],
          "compression": "none",
          "packed_context_free_data": "",
          "context_free_data": [],
          "packed_trx": "11b3185bd48f4ef64b02000000000100a6823403ea3055000000572d3ccdcd01000000000000003000000000a8ed32322300000000000000300000000000b0967a102700000000000004454f530000000002313100",
          "transaction": {
            "expiration": "2018-06-07T04:22:41",
            "ref_block_num": 36820,
            "ref_block_prefix": 38532686,
            "max_net_usage_words": 0,
            "max_cpu_usage_ms": 0,
            "delay_sec": 0,
            "context_free_actions": [],
            "actions": [
              {
                "account": "eosio.token",
                "name": "transfer",
                "authorization": [
                  {
                    "actor": "a",
                    "permission": "active"
                  }
                ],
                "data": {
                  "from": "a",
                  "to": "jeff",
                  "quantity": "1.0000 EOS",
                  "memo": "11"
                },
                "hex_data": "00000000000000300000000000b0967a102700000000000004454f5300000000023131"
              }
            ],
            "transaction_extensions": []
          }
        }
      }
    ],
    "block_extensions": [],
    "id": "000a912638bdb6d094b6af9ae0251f85cecbc4a48f25538e8ee9cd03e518d2b8",
    "block_num": 692518,
    "ref_block_prefix": 2595206804
}
```

### 交易信息返回格式
```json
{
    "id":"4e8fdd91058a90363e03d4539db0a757855d73ba1045b34467f4287b3eca720b",
    "trx":{
        "receipt":{
            "status":"executed",
            "cpu_usage_us":2819,
            "net_usage_words":20,
            "trx":[
                1,
                {
                    "signatures":[
                        "SIG_K1_K8bymZS9FoaTYycshYuceoniEGHrHJAyDwnyQfGh74WNjMqah6eLHFiDAPS8JcVYftys5zxS4T3iaVp2mqwxSNmzixn6Gs"
                    ],
                    "compression":"none",
                    "packed_context_free_data":"",
                    "packed_trx":"e7b4185b2502fdf85cb2000000000100a6823403ea3055000000572d3ccdcd0100a6823403ea305500000000a8ed32324100a6823403ea305500000857619db1ca00ca9a3b0000000004454f5300000000205472616e736665722066726f6d206e6f70726f6d20746f207869616f6d696e6700"
                }
            ]
        },
        "trx":{
            "expiration":"2018-06-07T04:30:31",
            "ref_block_num":549,
            "ref_block_prefix":2992437501,
            "max_net_usage_words":0,
            "max_cpu_usage_ms":0,
            "delay_sec":0,
            "context_free_actions":[

            ],
            "actions":[
                {
                    "account":"eosio.token",
                    "name":"transfer",
                    "authorization":[
                        {
                            "actor":"eosio.token",
                            "permission":"active"
                        }
                    ],
                    "data":{
                        "from":"eosio.token",
                        "to":"testuser1",
                        "quantity":"100000.0000 EOS",
                        "memo":"Transfer from noprom to xiaoming"
                    },
                    "hex_data":"00a6823403ea305500000857619db1ca00ca9a3b0000000004454f5300000000205472616e736665722066726f6d206e6f70726f6d20746f207869616f6d696e67"
                }
            ],
            "transaction_extensions":[

            ],
            "signatures":[
                "SIG_K1_K8bymZS9FoaTYycshYuceoniEGHrHJAyDwnyQfGh74WNjMqah6eLHFiDAPS8JcVYftys5zxS4T3iaVp2mqwxSNmzixn6Gs"
            ],
            "context_free_data":[

            ]
        }
    },
    "block_time":"2018-06-07T04:30:01.500",
    "block_num":551,
    "last_irreversible_block":719,
    "traces":[
        {
            "receipt":{
                "receiver":"eosio.token",
                "act_digest":"97e6c9cb742f76d188fc6fcc4618fdee63fe5c4392330d609a53e7fc72f52776",
                "global_sequence":559,
                "recv_sequence":3,
                "auth_sequence":[
                    [
                        "eosio.token",
                        5
                    ]
                ],
                "code_sequence":1,
                "abi_sequence":1
            },
            "act":{
                "account":"eosio.token",
                "name":"transfer",
                "authorization":[
                    {
                        "actor":"eosio.token",
                        "permission":"active"
                    }
                ],
                "data":{
                    "from":"eosio.token",
                    "to":"testuser1",
                    "quantity":"100000.0000 EOS",
                    "memo":"Transfer from noprom to xiaoming"
                },
                "hex_data":"00a6823403ea305500000857619db1ca00ca9a3b0000000004454f5300000000205472616e736665722066726f6d206e6f70726f6d20746f207869616f6d696e67"
            },
            "elapsed":2153,
            "cpu_usage":0,
            "console":"",
            "total_cpu_usage":0,
            "trx_id":"4e8fdd91058a90363e03d4539db0a757855d73ba1045b34467f4287b3eca720b",
            "inline_traces":[
                {
                    "receipt":{
                        "receiver":"testuser1",
                        "act_digest":"97e6c9cb742f76d188fc6fcc4618fdee63fe5c4392330d609a53e7fc72f52776",
                        "global_sequence":560,
                        "recv_sequence":1,
                        "auth_sequence":[
                            [
                                "eosio.token",
                                6
                            ]
                        ],
                        "code_sequence":1,
                        "abi_sequence":1
                    },
                    "act":{
                        "account":"eosio.token",
                        "name":"transfer",
                        "authorization":[
                            {
                                "actor":"eosio.token",
                                "permission":"active"
                            }
                        ],
                        "data":{
                            "from":"eosio.token",
                            "to":"testuser1",
                            "quantity":"100000.0000 EOS",
                            "memo":"Transfer from noprom to xiaoming"
                        },
                        "hex_data":"00a6823403ea305500000857619db1ca00ca9a3b0000000004454f5300000000205472616e736665722066726f6d206e6f70726f6d20746f207869616f6d696e67"
                    },
                    "elapsed":50,
                    "cpu_usage":0,
                    "console":"",
                    "total_cpu_usage":0,
                    "trx_id":"4e8fdd91058a90363e03d4539db0a757855d73ba1045b34467f4287b3eca720b",
                    "inline_traces":[

                    ]
                }
            ]
        },
        {
            "receipt":{
                "receiver":"testuser1",
                "act_digest":"97e6c9cb742f76d188fc6fcc4618fdee63fe5c4392330d609a53e7fc72f52776",
                "global_sequence":560,
                "recv_sequence":1,
                "auth_sequence":[
                    [
                        "eosio.token",
                        6
                    ]
                ],
                "code_sequence":1,
                "abi_sequence":1
            },
            "act":{
                "account":"eosio.token",
                "name":"transfer",
                "authorization":[
                    {
                        "actor":"eosio.token",
                        "permission":"active"
                    }
                ],
                "data":{
                    "from":"eosio.token",
                    "to":"testuser1",
                    "quantity":"100000.0000 EOS",
                    "memo":"Transfer from noprom to xiaoming"
                },
                "hex_data":"00a6823403ea305500000857619db1ca00ca9a3b0000000004454f5300000000205472616e736665722066726f6d206e6f70726f6d20746f207869616f6d696e67"
            },
            "elapsed":50,
            "cpu_usage":0,
            "console":"",
            "total_cpu_usage":0,
            "trx_id":"4e8fdd91058a90363e03d4539db0a757855d73ba1045b34467f4287b3eca720b",
            "inline_traces":[

            ]
        }
    ]
}
```
