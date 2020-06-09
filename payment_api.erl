-module(payment_api).
-export([handle/1]).

handle(#{ method := <<"POST">>,
          path := <<"/v1/payments">>,
          params := #{
            id := PaymentId
           },
          headers := #{
            authorization := <<"Bearer ", Token/binary>> 
           },
          body := #{
            from := From,
             to := To,
             amount := Amount,
             currency := Currency 
           }
        }) ->

    {ok, Token, PaymentId, From, To, Amount, Currency}.
