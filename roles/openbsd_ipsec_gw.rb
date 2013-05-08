name 'openbsd_ipsec_gw'
description 'IPSec gateway'
run_list %w{
  recipe[openbsd::ipsec_responder_test]
}

default_attributes(
  "openbsd" => {
    "ipsec" => {
      "is_gateway" => true
    }
  }
)
