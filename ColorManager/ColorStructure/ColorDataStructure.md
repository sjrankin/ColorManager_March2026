Source data is defined in Colorlist.xml.

The structure of the color database and internal layout is:

Colors
- Version Block
  - File Version
  - Data Version
  - Legal Block
  - Save Data
  
Color Group
  - 0 or more of Color
  - 0 or more of Color Group
  - 0 or more of Color Collection
  
Color Collection
  - 0 or more of Color
  - 0 or more of Color Collection
  
Color
  - 0 or more of Color Variant
  
Colors is defined in Colors.swift
Version Block is defined in VersionBlock.swift
Data Version is defined in DataVersionBlock.swift
File Version is defined in FileVersionBlock.swift
Legal Block is defined in LegalTextBlock.swift
Save Data is defined in SaveDataBlock.swift

Color Group is defined in ColorGroup.swift
Color Collection is defined in ColorCollection.swift
Color is defined in ColorRecord.swift
Color variant is defined in ColorVariant.swift

Color Spaces are defined in ColorSpaces.swift and in files in the ColorSpaceRecords directory.
