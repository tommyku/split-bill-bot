# frozen_string_literal: true
require 'telegram/bot'
require 'envyable'
require 'awesome_print'

START_MESSAGE = '''
Hi, I am split bill bot, tell me how you wanna split the bill.
For example, \'split 145 for 3 of us\'.
I can somehow read Chinese too: \'6人200蚊\'
'''

Envyable.load(File.expand_path('env.yml', File.dirname( __FILE__)))


def handle_command(message)
  command, param = parse_command(message.text)
  case command
  when /\/start/i
    @bot.api.send_message(chat_id: message.chat.id, text: START_MESSAGE)
  end
end

def parse_command(text)
  text.split(' ', 2)
end

def is_command?(message)
  message[:entities].each do |val|
    return true if val[:type] == 'bot_command'
  end
  false
end

def handle_message(message)
  numbers = extract_numbers(message.text)
  split = (numbers.first.to_f / numbers.last.to_f).round(2)
  @bot.api.send_message(chat_id: message.chat.id, text: "I guess #{split} but don't count on that")
end

def extract_numbers(text)
  number_regexp = /(\d+,*\d*\.?\d*)/
  numbers = text.scan number_regexp
  bill_candidate = 0
  headcount_candidate = numbers.first.last.to_f
  numbers.each do |number|
    number = number.last.to_f
    if bill_candidate < number
      bill_candidate = number
    end
    if headcount_candidate > number
      headcount_candidate = number
    end
  end
  [bill_candidate, headcount_candidate]
end

Telegram::Bot::Client.run(ENV['TELEGRAM_BOT_TOKEN']) do |bot|
  @bot = bot
  @bot.listen do |message|
    ap message
    if is_command?(message)
      handle_command(message)
    else
      handle_message(message)
    end
  end
end

