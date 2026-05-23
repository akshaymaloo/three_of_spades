import re

def main():
    with open('lib/screens/home_screen.dart', 'r') as f:
        content = f.read()

    # The missing closing parenthesis for Flexible/Semantics
    bot_card_end = """                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),"""
    bot_card_end_new = """                                  ),
                                ),
                              ),
                             ),
                            ),
                            const SizedBox(height: 16),"""
    content = content.replace(bot_card_end, bot_card_end_new, 1)

    # The missing closing parenthesis for _buildModeCard Semantics
    mode_card_end = """        ),
      ),
    );
  }
}"""
    mode_card_end_new = """        ),
       ),
      ),
    );
  }
}"""
    content = content.replace(mode_card_end, mode_card_end_new, 1)

    with open('lib/screens/home_screen.dart', 'w') as f:
        f.write(content)

if __name__ == '__main__':
    main()
