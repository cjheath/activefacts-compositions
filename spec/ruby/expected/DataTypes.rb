require 'activefacts/api'

module DataTypes
  class AlternateAutoCounter < AutoCounter
    value_type
  end

  class AACET
    identified_by   :alternate_auto_counter
    one_to_one      :alternate_auto_counter, mandatory: true  # AAC_ET has Alternate Auto Counter, see AlternateAutoCounter#aac_et
  end

  class AACSub < AACET
  end

  class AlternateGuid < Guid
    value_type
  end

  class AGET
    identified_by   :alternate_guid
    one_to_one      :alternate_guid, mandatory: true    # AG_ET has Alternate Guid, see AlternateGuid#ag_et
  end

  class AGSub < AGET
  end

  class AlternateAutoTimeStamp < AutoTimeStamp
    value_type
  end

  class AlternateBigInt < BigInt
    value_type
  end

  class AlternateBit < Bit
    value_type
  end

  class AlternateCharacter < Character
    value_type
  end

  class AlternateCurrency < Currency
    value_type
  end

  class AlternateDateTime < DateTime
    value_type
  end

  class AlternateDouble < Double
    value_type
  end

  class AlternateFixedLengthText < FixedLengthText
    value_type
  end

  class AlternateFloat < Float
    value_type
  end

  class Int < Integer
    value_type
  end

  class AlternateInt < Int
    value_type
  end

  class AlternateLargeLengthText < LargeLengthText
    value_type
  end

  class AlternateNationalCharacter < NationalCharacter
    value_type
  end

  class AlternateNationalCharacterVarying < NationalCharacterVarying
    value_type
  end

  class AlternateNchar < Nchar
    value_type
  end

  class AlternateNvarchar < Nvarchar
    value_type
  end

  class AlternatePictureRawData < PictureRawData
    value_type
  end

  class AlternateSignedInt < SignedInt
    value_type
  end

  class AlternateSignedInteger < SignedInteger
    value_type
  end

  class AlternateSmallInt < SmallInt
    value_type
  end

  class AlternateTimeStamp < TimeStamp
    value_type
  end

  class AlternateTinyInt < TinyInt
    value_type
  end

  class AlternateUnsigned < Unsigned
    value_type
  end

  class AlternateUnsignedInt < UnsignedInt
    value_type
  end

  class AlternateUnsignedInteger < UnsignedInteger
    value_type
  end

  class AlternateVarchar < Varchar
    value_type
  end

  class AlternateVariableLengthRawData < VariableLengthRawData
    value_type
  end

  class AlternateVariableLengthText < VariableLengthText
    value_type
  end

  class Byte < Integer
    value_type
  end

  class Char8 < Char
    value_type      length: 8
  end

  class Name < String
    value_type
  end

  class ContainerName < Name
    value_type
  end

  class Decimal14 < Decimal
    value_type      length: 14
  end

  class Decimal14_6 < Decimal
    value_type      length: 14
  end

  class Decimal8_3 < Decimal
    value_type      length: 8
  end

  class FundamentalBinary < Binary
    value_type
  end

  class FundamentalBoolean < Boolean
    value_type
  end

  class FundamentalChar < Char
    value_type
  end

  class FundamentalDate < Date
    value_type
  end

  class FundamentalDateTime < DateTime
    value_type
  end

  class FundamentalDecimal < Decimal
    value_type
  end

  class FundamentalInteger < Integer
    value_type
  end

  class FundamentalMoney < Money
    value_type
  end

  class FundamentalReal < Real
    value_type
  end

  class FundamentalString < String
    value_type
  end

  class FundamentalText < Text
    value_type
  end

  class FundamentalTime < Time
    value_type
  end

  class FundamentalTimestamp < Timestamp
    value_type
  end

  class Int16 < Integer
    value_type      length: 16
  end

  class Int32 < Integer
    value_type      length: 32
  end

  class Int64 < Integer
    value_type      length: 64
  end

  class Int8 < Integer
    value_type      length: 8
  end

  class Int80 < Integer
    value_type      length: 80
  end

  class Large < Integer
    value_type
  end

  class Quad < Integer
    value_type
  end

  class Real32 < Real
    value_type      length: 32
  end

  class Real64 < Real
    value_type      length: 64
  end

  class Real80 < Real
    value_type      length: 80
  end

  class String255 < String
    value_type      length: 255
  end

  class Text65536 < Text
    value_type      length: 65536
  end

  class UByte < Integer
    value_type
  end

  class UInt < Integer
    value_type
  end

  class ULarge < Integer
    value_type
  end

  class UQuad < Integer
    value_type
  end

  class UWord < Integer
    value_type
  end

  class Word < Integer
    value_type
  end

  class Container
    identified_by   :container_name
    one_to_one      :container_name, mandatory: true    # Container has Container Name, see ContainerName#container
    has_one         :alternate_auto_counter, mandatory: true  # Container has Alternate Auto Counter, see AlternateAutoCounter#all_container
    has_one         :alternate_auto_time_stamp, mandatory: true  # Container has Alternate Auto Time Stamp, see AlternateAutoTimeStamp#all_container
    has_one         :alternate_big_int, mandatory: true  # Container has Alternate Big Int, see AlternateBigInt#all_container
    has_one         :alternate_bit, mandatory: true     # Container has Alternate Bit, see AlternateBit#all_container
    has_one         :alternate_character, mandatory: true  # Container has Alternate Character, see AlternateCharacter#all_container
    has_one         :alternate_currency, mandatory: true  # Container has Alternate Currency, see AlternateCurrency#all_container
    has_one         :alternate_date_time, mandatory: true  # Container has Alternate Date Time, see AlternateDateTime#all_container
    has_one         :alternate_double, mandatory: true  # Container has Alternate Double, see AlternateDouble#all_container
    has_one         :alternate_fixed_length_text, mandatory: true  # Container has Alternate Fixed Length Text, see AlternateFixedLengthText#all_container
    has_one         :alternate_float, mandatory: true   # Container has Alternate Float, see AlternateFloat#all_container
    has_one         :alternate_guid, mandatory: true    # Container has Alternate Guid, see AlternateGuid#all_container
    has_one         :alternate_int, mandatory: true     # Container has Alternate Int, see AlternateInt#all_container
    has_one         :alternate_large_length_text, mandatory: true  # Container has Alternate Large Length Text, see AlternateLargeLengthText#all_container
    has_one         :alternate_national_character, mandatory: true  # Container has Alternate National Character, see AlternateNationalCharacter#all_container
    has_one         :alternate_national_character_varying, mandatory: true  # Container has Alternate National Character Varying, see AlternateNationalCharacterVarying#all_container
    has_one         :alternate_nchar, mandatory: true   # Container has Alternate Nchar, see AlternateNchar#all_container
    has_one         :alternate_nvarchar, mandatory: true  # Container has Alternate Nvarchar, see AlternateNvarchar#all_container
    has_one         :alternate_picture_raw_data, mandatory: true  # Container has Alternate Picture Raw Data, see AlternatePictureRawData#all_container
    has_one         :alternate_signed_int, mandatory: true  # Container has Alternate Signed Int, see AlternateSignedInt#all_container
    has_one         :alternate_signed_integer, mandatory: true  # Container has Alternate Signed Integer, see AlternateSignedInteger#all_container
    has_one         :alternate_small_int, mandatory: true  # Container has Alternate Small Int, see AlternateSmallInt#all_container
    has_one         :alternate_time_stamp, mandatory: true  # Container has Alternate Time Stamp, see AlternateTimeStamp#all_container
    has_one         :alternate_tiny_int, mandatory: true  # Container has Alternate Tiny Int, see AlternateTinyInt#all_container
    has_one         :alternate_unsigned, mandatory: true  # Container has Alternate Unsigned, see AlternateUnsigned#all_container
    has_one         :alternate_unsigned_int, mandatory: true  # Container has Alternate Unsigned Int, see AlternateUnsignedInt#all_container
    has_one         :alternate_unsigned_integer, mandatory: true  # Container has Alternate Unsigned Integer, see AlternateUnsignedInteger#all_container
    has_one         :alternate_varchar, mandatory: true  # Container has Alternate Varchar, see AlternateVarchar#all_container
    has_one         :alternate_variable_length_raw_data, mandatory: true  # Container has Alternate Variable Length Raw Data, see AlternateVariableLengthRawData#all_container
    has_one         :alternate_variable_length_text, mandatory: true  # Container has Alternate Variable Length Text, see AlternateVariableLengthText#all_container
    has_one         :byte, mandatory: true              # Container has Byte, see Byte#all_container
    has_one         :char8, mandatory: true             # Container has Char8, see Char8#all_container
    has_one         :decimal14, mandatory: true         # Container has Decimal14, see Decimal14#all_container
    has_one         :decimal14__6, mandatory: true      # Container has Decimal14_6, see Decimal14_6#all_container
    has_one         :decimal8__3, mandatory: true       # Container has Decimal8_3, see Decimal8_3#all_container
    has_one         :fundamental_binary, mandatory: true  # Container has Fundamental Binary, see FundamentalBinary#all_container
    has_one         :fundamental_boolean, mandatory: true  # Container has Fundamental Boolean, see FundamentalBoolean#all_container
    has_one         :fundamental_char, mandatory: true  # Container has Fundamental Char, see FundamentalChar#all_container
    has_one         :fundamental_date, mandatory: true  # Container has Fundamental Date, see FundamentalDate#all_container
    has_one         :fundamental_date_time, mandatory: true  # Container has Fundamental DateTime, see FundamentalDateTime#all_container
    has_one         :fundamental_decimal, mandatory: true  # Container has Fundamental Decimal, see FundamentalDecimal#all_container
    has_one         :fundamental_integer, mandatory: true  # Container has Fundamental Integer, see FundamentalInteger#all_container
    has_one         :fundamental_money, mandatory: true  # Container has Fundamental Money, see FundamentalMoney#all_container
    has_one         :fundamental_real, mandatory: true  # Container has Fundamental Real, see FundamentalReal#all_container
    has_one         :fundamental_string, mandatory: true  # Container has Fundamental String, see FundamentalString#all_container
    has_one         :fundamental_text, mandatory: true  # Container has Fundamental Text, see FundamentalText#all_container
    has_one         :fundamental_time, mandatory: true  # Container has Fundamental Time, see FundamentalTime#all_container
    has_one         :fundamental_timestamp, mandatory: true  # Container has Fundamental Timestamp, see FundamentalTimestamp#all_container
    has_one         :int, mandatory: true               # Container has Int, see Int#all_container
    has_one         :int16, mandatory: true             # Container has Int16, see Int16#all_container
    has_one         :int32, mandatory: true             # Container has Int32, see Int32#all_container
    has_one         :int64, mandatory: true             # Container has Int64, see Int64#all_container
    has_one         :int8, mandatory: true              # Container has Int8, see Int8#all_container
    has_one         :int80, mandatory: true             # Container has Int80, see Int80#all_container
    has_one         :large, mandatory: true             # Container has Large, see Large#all_container
    has_one         :quad, mandatory: true              # Container has Quad, see Quad#all_container
    has_one         :real32, mandatory: true            # Container has Real32, see Real32#all_container
    has_one         :real64, mandatory: true            # Container has Real64, see Real64#all_container
    has_one         :real80, mandatory: true            # Container has Real80, see Real80#all_container
    has_one         :string255, mandatory: true         # Container has String255, see String255#all_container
    has_one         :text65536, mandatory: true         # Container has Text65536, see Text65536#all_container
    has_one         :u_byte, mandatory: true            # Container has UByte, see UByte#all_container
    has_one         :u_int, mandatory: true             # Container has UInt, see UInt#all_container
    has_one         :u_large, mandatory: true           # Container has ULarge, see ULarge#all_container
    has_one         :u_quad, mandatory: true            # Container has UQuad, see UQuad#all_container
    has_one         :u_word, mandatory: true            # Container has UWord, see UWord#all_container
    has_one         :word, mandatory: true              # Container has Word, see Word#all_container
  end
end
