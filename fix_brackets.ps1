$path = "lib\screens\dashboard_screens\my_card_screen.dart"
$content = Get-Content $path -Raw

# Replace:
#                                                          ),
#                                                        ],
#                                                      ),
#                                                    ],
#                                                  ),
#                                      ),
# With the correct balanced indentation:
#                                                           ],
#                                                         ),
#                                                       ],
#                                                     ),
#                                                   ],
#                                                 ),
#                                     ),

$oldBlock = "                                                         ),`r`n                                                       ],`r`n                                                     ),`r`n                                                   ],`r`n                                                 ),`r`n                                     ),"
$newBlock = "                                                          ],`r`n                                                         ),`r`n                                                       ],`r`n                                                     ),`r`n                                                   ],`r`n                                                 ),`r`n                                     ),"

# Also handle linux newlines just in case
$oldBlockUnix = "                                                         ),\n                                                       ],\n                                                     ),\n                                                   ],\n                                                 ),\n                                     ),"
$newBlockUnix = "                                                          ],\n                                                         ),\n                                                       ],\n                                                     ),\n                                                   ],\n                                                 ),\n                                     ),"

if ($content.Contains($oldBlock)) {
    $content = $content.Replace($oldBlock, $newBlock)
    Write-Output "Fixed CR-LF brackets!"
} elseif ($content.Contains($oldBlockUnix)) {
    $content = $content.Replace($oldBlockUnix, $newBlockUnix)
    Write-Output "Fixed LF brackets!"
} else {
    Write-Output "Brackets block not matched directly, using regex..."
    # Fallback to a regex replacement that matches the pattern regardless of spacing and newline types
    $pattern = '(?m)^\s*\),\s*^\s*\]\,\s*^\s*\),\s*^\s*\]\,\s*^\s*\),\s*^\s*\),'
    # Let's write the exact replacement lines
    $replacement = "                                                          ],`r`n                                                         ),`r`n                                                       ],`r`n                                                     ),`r`n                                                   ],`r`n                                                 ),"
    $content = [System.Text.RegularExpressions.Regex]::Replace($content, $pattern, $replacement)
}

Set-Content $path $content -NoNewline
Write-Output "Bracket fix run complete!"
