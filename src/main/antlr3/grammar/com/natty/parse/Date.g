grammar Date;

options {
  output=AST;
}

tokens {
  INT;
  HOURS;
  MINUTES;
  AM_PM;
  SPAN;
  MONTH_OF;
  DAY_OF_WEEK;
  DAY_OF_MONTH;
  YEAR_OF;
  SEEK_DIR;
  SEEK_TYPE;
  EXPLICIT_TIME;
  EXPLICIT_DATE;
  RELATIVE_DATE;
  DATE_TIME;
}

@header        { package com.natty.parse; }
@lexer::header { package com.natty.parse; }

date_time
  options{backtrack=true;}
  : (((date (COMMA | AT)? time)=> date time) | time (COMMA | ON)? date)
    -> ^(DATE_TIME date time)
    
  | date
    -> ^(DATE_TIME date)
  
  | time
    -> ^(DATE_TIME time)
  ;
  
date
  : formal_date
  | month_and_day_date
  ;
  
formal_date
  // year first: 1979-02-28, 1980/01/02, etc.  full 4 digit year required to match
  : int_4_digits date_separator int_1_to_12 date_separator int_1_to_31
    -> ^(EXPLICIT_DATE ^(MONTH_OF int_1_to_12) ^(DAY_OF_MONTH int_1_to_31) ^(YEAR_OF int_4_digits))
 
  // year last: 1/02/1980, 2/28/79.  1 to 4 digit year is acceptable 
  | int_1_to_12 date_separator int_1_to_31 (date_separator int_up_to_4_digits)?
    -> ^(EXPLICIT_DATE ^(MONTH_OF int_1_to_31) ^(DAY_OF_MONTH int_1_to_31) ^(YEAR_OF int_up_to_4_digits?))
  ;

// an explicit date made up of a month name, the day of the month, and an optional year
month_and_day_date
  : (day_of_month OF? month year? | month day_of_month year?)
    -> ^(EXPLICIT_DATE month day_of_month year?)
  ;
  
month
  : JANUARY   -> ^(MONTH_OF INT["1"])
  | FEBRUARY  -> ^(MONTH_OF INT["2"])
  | MARCH     -> ^(MONTH_OF INT["3"])
  | APRIL     -> ^(MONTH_OF INT["4"])
  | MAY       -> ^(MONTH_OF INT["5"])
  | JUNE      -> ^(MONTH_OF INT["6"])
  | JULY      -> ^(MONTH_OF INT["7"])
  | AUGUST    -> ^(MONTH_OF INT["8"])
  | SEPTEMBER -> ^(MONTH_OF INT["9"])
  | OCTOBER   -> ^(MONTH_OF INT["10"])
  | NOVEMBER  -> ^(MONTH_OF INT["11"])
  | DECEMBER  -> ^(MONTH_OF INT["12"])
  ;
  
day_of_month
  : spelled_or_int_1_to_31   -> ^(DAY_OF_MONTH spelled_or_int_1_to_31)
  | spelled_sequence_1_to_31 -> ^(DAY_OF_MONTH spelled_sequence_1_to_31) 
  ;
  
year
  : COMMA? (IN THE YEAR)? SINGLE_QUOTE int_0_to_99_with_prefix  -> ^(YEAR_OF int_0_to_99_with_prefix)
  | COMMA? (IN THE YEAR)? int_3_or_4_digits                     -> ^(YEAR_OF int_3_or_4_digits)
  ;
  
date_separator
  : DASH
  | SLASH
  ;
  
time 
  : hours (COLON? minutes)? meridian_indicator?
    -> ^(EXPLICIT_TIME hours minutes? meridian_indicator?)
  
  | time_identifier
  ;
  
// common time identifiers (noon, midnight, etc)
time_identifier
  : MIDNIGHT -> ^(EXPLICIT_TIME ^(HOURS INT["12"]) AM_PM["am"])
  | NOON     -> ^(EXPLICIT_TIME ^(HOURS INT["12"]) AM_PM["pm"])
  ;
  
hours
  : int_0_to_23 -> ^(HOURS int_0_to_23)
  ;
  
minutes
  : int_0_to_59 -> ^(MINUTES int_0_to_59)
  ;
  
meridian_indicator
  : AM -> AM_PM["am"]
  | PM -> AM_PM["pm"]
  ;
  
// a number between 1 and 31 spelled-out (one, twenty-eight, etc.)
spelled_or_int_1_to_31
  : int_1_to_31
  | spelled_1_to_31
  ;
  
spelled_1_to_31
  : ONE        -> INT["1"]
  | TWO        -> INT["2"]
  | THREE      -> INT["3"]
  | FOUR       -> INT["4"]
  | FIVE       -> INT["5"]
  | SIX        -> INT["6"]
  | SEVEN      -> INT["7"]
  | EIGHT      -> INT["8"]
  | NINE       -> INT["9"]
  | TEN        -> INT["10"]
  | ELEVEN     -> INT["11"]
  | TWELVE     -> INT["12"]
  | THIRTEEN   -> INT["13"]
  | FOURTEEN   -> INT["14"]
  | FIFTEEN    -> INT["15"]
  | SIXTEEN    -> INT["16"]
  | SEVENTEEN  -> INT["17"]
  | EIGHTEEN   -> INT["18"]
  | NINETEEN   -> INT["19"]
  | TWENTY     -> INT["20"]
  | TWENTY DASH? ONE   -> INT["21"]
  | TWENTY DASH? TWO   -> INT["22"]
  | TWENTY DASH? THREE -> INT["23"]
  | TWENTY DASH? FOUR  -> INT["24"]
  | TWENTY DASH? FIVE  -> INT["25"]
  | TWENTY DASH? SIX   -> INT["26"]
  | TWENTY DASH? SEVEN -> INT["27"]
  | TWENTY DASH? EIGHT -> INT["28"]
  | TWENTY DASH? NINE  -> INT["29"]
  | THIRTY             -> INT["30"]
  | THIRTY DASH? ONE   -> INT["31"]
  ;
  
// a number in sequence between 1 and 31, either spelled-out
// or suffixed (first, 2nd, twenty-first, etc)
spelled_sequence_1_to_31
  : FIRST       -> INT["1"]
  | SECOND      -> INT["2"]
  | THIRD       -> INT["3"]
  | FOURTH      -> INT["4"]
  | FIFTH       -> INT["5"]
  | SIXTH       -> INT["6"]
  | SEVENTH     -> INT["7"]
  | EIGHTH      -> INT["8"]
  | NINTH       -> INT["9"]
  | TENTH       -> INT["10"]
  | ELEVENTH    -> INT["11"]
  | TWELFTH     -> INT["12"]
  | THIRTEENTH  -> INT["13"]
  | FOURTEENTH  -> INT["14"]
  | FIFTEENTH   -> INT["15"]
  | SIXTEENTH   -> INT["16"]
  | SEVENTEENTH -> INT["17"]
  | EIGHTEENTH  -> INT["18"]
  | NINETEENTH  -> INT["19"]
  | TWENTIETH   -> INT["20"]
  | (TWENTY_FIRST   | (TWENTY DASH? FIRST))   -> INT["21"]
  | (TWENTY_SECOND  | (TWENTY DASH? SECOND))  -> INT["22"]
  | (TWENTY_THIRD   | (TWENTY DASH? THIRD))   -> INT["23"]
  | (TWENTY_FOURTH  | (TWENTY DASH? FOURTH))  -> INT["24"]
  | (TWENTY_FIFTH   | (TWENTY DASH? FIFTH))   -> INT["25"]
  | (TWENTY_SIXTH   | (TWENTY DASH? SIXTH))   -> INT["26"]
  | (TWENTY_SEVENTH | (TWENTY DASH? SEVENTH)) -> INT["27"]
  | (TWENTY_EIGHTH  | (TWENTY DASH? EIGHTH))  -> INT["28"]
  | (TWENTY_NINTH   | (TWENTY DASH? NINTH))   -> INT["29"]
  | THIRTIETH                                 -> INT["30"]
  | (THIRTY_FIRST   | (THIRTY DASH? FIRST))   -> INT["31"]
  ;
  
// up to 4 subsequent digits
int_up_to_4_digits
  : int_0_to_99_optional_prefix
  | int_3_or_4_digits 
  ;
  
// 3 or 4 subsequent digits
int_3_or_4_digits
  : THREE_DIGIT -> INT[$THREE_DIGIT.text]
  | int_4_digits
  ;
  
// exactly 4 subsequent digits
int_4_digits
  : FOUR_DIGIT -> INT[$FOUR_DIGIT.text]
  ;
  
int_1_to_12
  : PREFIXED_ONE_TO_NINE -> INT[$PREFIXED_ONE_TO_NINE.text]
  | ONE_TO_NINE          -> INT[$ONE_TO_NINE.text]
  | TEN_TO_TWELVE        -> INT[$TEN_TO_TWELVE.text]
  ;
  
// number between 0 and 23 with an optional 0 prefix for numbers 0-9
int_0_to_23
  : TWO_ZEROS                -> INT[$TWO_ZEROS.text]
  | ZERO                     -> INT[$ZERO.text]
  | int_1_to_12
  | THIRTEEN_TO_TWENTY_THREE -> INT[$THIRTEEN_TO_TWENTY_THREE.text]
  ;
  
// number between 0 and 59 with an optional 0 prefix for numbers 0-9
int_0_to_59
  : int_0_to_23
  | TWENTY_FOUR_TO_THIRTY_ONE -> INT[$TWENTY_FOUR_TO_THIRTY_ONE.text]
  | THIRTY_TWO_TO_FIFTY_NINE  -> INT[$THIRTY_TWO_TO_FIFTY_NINE.text]
  ;
  
// number between 0 and 99 with an optional 0 prefix for numbers 0-9
int_0_to_99_no_prefix
  : int_0_to_59
  | SIXTY_TO_NINETY_NINE      -> INT[$SIXTY_TO_NINETY_NINE.text]
  ;
  
int_0_to_99_with_prefix
  : TWO_ZEROS                 -> INT[$TWO_ZEROS.text]
  | PREFIXED_ONE_TO_NINE      -> INT[$PREFIXED_ONE_TO_NINE.text]
  | TEN_TO_TWELVE             -> INT[$TEN_TO_TWELVE.text]
  | THIRTEEN_TO_TWENTY_THREE  -> INT[$THIRTEEN_TO_TWENTY_THREE.text]
  | TWENTY_FOUR_TO_THIRTY_ONE -> INT[$TWENTY_FOUR_TO_THIRTY_ONE.text]
  | THIRTY_TWO_TO_FIFTY_NINE  -> INT[$THIRTY_TWO_TO_FIFTY_NINE.text]
  | SIXTY_TO_NINETY_NINE      -> INT[$SIXTY_TO_NINETY_NINE.text]
  ;
  
int_0_to_99_optional_prefix
  : int_0_to_99_with_prefix
  | ONE_TO_NINE -> INT[$ONE_TO_NINE.text]
  | ZERO        -> INT[$ZERO.text]
  ;

// number between 1 and 31 with an optional 0 prefix for numbers 0-9
int_1_to_31
  : PREFIXED_ONE_TO_NINE      -> INT[$PREFIXED_ONE_TO_NINE.text]
  | ONE_TO_NINE               -> INT[$ONE_TO_NINE.text]
  | int_10_to_31
  ;
  
int_1_to_31_no_prefix
  : ONE_TO_NINE -> INT[$ONE_TO_NINE.text]
  | int_10_to_31
  ;
  
int_10_to_31
  : TEN_TO_TWELVE             -> INT[$TEN_TO_TWELVE.text]
  | THIRTEEN_TO_TWENTY_THREE  -> INT[$THIRTEEN_TO_TWENTY_THREE.text]
  | TWENTY_FOUR_TO_THIRTY_ONE -> INT[$TWENTY_FOUR_TO_THIRTY_ONE.text]
  ;
  
// time identifiers
MIDNIGHT : 'midnight' | 'mid-night';
NOON     : 'noon';

IN  : 'in';
THE : 'the';
AT  : 'at';
ON  : 'on';
OF  : 'of';

// seek directions
THIS     : 'this';
AFTER    : 'after';
BEFORE   : 'before';
LAST     : 'last';
PAST     : 'past';
NEXT     : 'next';
COMING   : 'coming';
UPCOMING : 'upcoming';
FROM_NOW : 'from now';
AGO      : 'ago';

// months
JANUARY   : 'january'   | 'jan';
FEBRUARY  : 'february'  | 'feb';
MARCH     : 'march'     | 'mar';
APRIL     : 'april'     | 'apr';
MAY       : 'may';
JUNE      : 'june'      | 'jun';
JULY      : 'july'      | 'jul';
AUGUST    : 'august'    | 'aug';
SEPTEMBER : 'september' | 'sep' | 'sept';
OCTOBER   : 'october'   | 'oct';
NOVEMBER  : 'november'  | 'nov';
DECEMBER  : 'december'  | 'dec';
  
// days of the week
SUNDAY    : 'sunday'    | 'sundays'    | 'sun'  | 'suns';
MONDAY    : 'monday'    | 'mondays'    | 'mon'  | 'mons';
TUESDAY   : 'tuesday'   | 'tuesdays'   | 'tues' | 'tue';
WEDNESDAY : 'wednesday' | 'wednesdays' | 'wed'  | 'weds';
THURSDAY  : 'thursday'  | 'thursdays'  | 'thur' | 'thu' | 'thus' | 'thurs';
FRIDAY    : 'friday'    | 'fridays'    | 'fri'  | 'fris';
SATURDAY  : 'saturday'  | 'saturdays'  | 'sat'  | 'sats';

// named days
TODAY     : 'today';
TOMORROW  : 'tomorow'   | 'tomorrow'   | 'tommorow' | 'tommorrow';
YESTERDAY : 'yesterday';
  
// meridian indicators
AM : 'am' | 'a.m.' | 'a';
PM : 'pm' | 'p.m.' | 'p';
  
//date units
DAY   : 'day'   | 'days' ;
WEEK  : 'week'  | 'weeks' ;
MONTH : 'month' | 'months' ;
YEAR  : 'year'  | 'years' ;
  
// spelled out numbers
ONE       : 'one';
TWO       : 'two';
THREE     : 'three';
FOUR      : 'four';
FIVE      : 'five';
SIX       : 'six';
SEVEN     : 'seven';
EIGHT     : 'eight';
NINE      : 'nine';
TEN       : 'ten';
ELEVEN    : 'eleven';
TWELVE    : 'twelve';
THIRTEEN  : 'thirteen';
FOURTEEN  : 'fourteen';
FIFTEEN   : 'fifteen';
SIXTEEN   : 'sixteen';
SEVENTEEN : 'seventeen';
EIGHTEEN  : 'eighteen' | 'eightteen';
NINETEEN  : 'nineteen';
TWENTY    : 'twenty';
THIRTY    : 'thirty';

// sequence numbers
FIRST          : 'first'       | '1st';
SECOND         : 'second'      | '2nd';
THIRD          : 'third'       | '3rd';
FOURTH         : 'fourth'      | '4th';
FIFTH          : 'fifth'       | '5th';
SIXTH          : 'sixth'       | '6th';
SEVENTH        : 'seventh'     | '7th';
EIGHTH         : 'eigth'       | '8th';
NINTH          : 'ninth'       | '9th';
TENTH          : 'tenth'       | '10th';
ELEVENTH       : 'eleventh'    | '11th';
TWELFTH        : 'twelfth'     | '12th';
THIRTEENTH     : 'thirteenth'  | '13th';
FOURTEENTH     : 'fourteenth'  | '14th';
FIFTEENTH      : 'fifteenth'   | '15th';
SIXTEENTH      : 'sixteenth'   | '16th';
SEVENTEENTH    : 'seventeenth' | '17th';
EIGHTEENTH     : 'eighteenth'  | '18th';
NINETEENTH     : 'nineteenth'  | '19th';
TWENTIETH      : 'twentieth'   | '20th';
TWENTY_FIRST   : '21st';
TWENTY_SECOND  : '22nd';
TWENTY_THIRD   : '23rd';
TWENTY_FOURTH  : '24th';
TWENTY_FIFTH   : '25th';
TWENTY_SIXTH   : '26th';
TWENTY_SEVENTH : '27th';
TWENTY_EIGHTH  : '28th';
TWENTY_NINTH   : '29th';
THIRTIETH      : 'thirtieth' | '30th';
THIRTY_FIRST   : '31st';

// 1 to nine prefixed with a zero
PREFIXED_ONE_TO_NINE : ZERO ONE_TO_NINE;

// 1 to nine with no zero prefix
ONE_TO_NINE : '1'..'9';

// a number between 1 and 12, 0 prefix optional for numbers 1 through 9
TEN_TO_TWELVE
  : '1' '0'..'2'
  ;
  
// a number between 13 and 24, inclusive
THIRTEEN_TO_TWENTY_THREE
  : '1' '3'..'9'
  | '2' '0'..'3'
  ;
  
// a number between 25 and 31, inclusive
TWENTY_FOUR_TO_THIRTY_ONE
  : '2' '4'..'9'
  | '3' '0'..'1'
  ;
  
// a number between 32 and 59, inclusive
THIRTY_TWO_TO_FIFTY_NINE
  : '3' '2'..'9'
  | '4'..'5' DIGIT 
  ;
  
// a number between 60 and 99, inclusive
SIXTY_TO_NINETY_NINE
  : '6'..'9' DIGIT
  ;
  
ZERO : '0';

TWO_ZEROS : '00';
  
THREE_DIGIT
  : DIGIT DIGIT DIGIT
  ;
  
FOUR_DIGIT
  : DIGIT DIGIT DIGIT DIGIT
  ;
  
DASH  : '-' ;
SLASH : '/' ;
COMMA : ',';
COLON : ':';
SINGLE_QUOTE : '\'';
  
WHITE_SPACE
  : (' ' | '\t' | '\n' | '\r')+ { $channel=HIDDEN; }
  ;

fragment DIGIT
  : '0'..'9'
  ;