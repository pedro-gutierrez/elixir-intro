-module(iban_checker).
-export([check/1]).

check(<<CountryCode:2/binary, 
        CheckNumber:2/binary,
        BankIdentifier:4/binary,
        SortCode:6/binary,
        AccountNumber:8/binary
      >>) -> {ok, #{
                country => CountryCode,
                check_number => CheckNumber,
                bank => BankIdentifier,
                sort_code => SortCode,
                account => AccountNumber
               }};
check(_) -> error.
