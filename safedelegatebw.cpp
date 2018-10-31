#include <eosiolib/eosio.hpp>
#include <eosiolib/currency.hpp>
#include <eosio.system/eosio.system.hpp>
#include <eosio.token/eosio.token.hpp>

using namespace eosio;
using namespace eosiosystem;
using std::string;

class safedelegatebw : contract {
public:
    using contract::contract;
    safedelegatebw( name self ) : contract(self){}

    // @abi action delegatebw
    void delegatebw(account_name to,
                    asset net_weight,
                    asset cpu_weight){

      require_auth(_self);

      INLINE_ACTION_SENDER(eosiosystem::system_contract, delegatebw)
      (N(eosio), {{_self, N(delegateperm)}}, {_self, to, net_weight, cpu_weight, false});
    }

    void apply( account_name contract, account_name action ) {
        if( contract != _self ) return;
        auto& thiscontract = *this;
        switch( action ) {
            EOSIO_API( safedelegatebw, (delegatebw) )
        };
    }
};

extern "C" {
  [[noreturn]] void apply( uint64_t receiver, uint64_t code, uint64_t action ) {
    safedelegatebw c( receiver );
    c.apply( code, action );
    eosio_exit(0);
  }
}
