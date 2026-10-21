<!-- gf-brief source=de9b30f143ed6ccb7b16e6562e01d12247bb029cb3aa5470b9bd1cddd3bea2c9 written=2026-10-22T00:08:50+03:00 -->
# Chickostan
## What it is
Chickostan is a habit counter for one person. You name habits, pin one of them, and add a tick only to the habit that is pinned. A tick on any other habit is kept as a miss and does not add. Optional daily caps, a seven-day log, and lists of ticks, misses, refused ticks, and removed ticks stay on this device.

## Launch and onboarding
Cold launch shows a placeholder titled "Today" and a blank card. If loading takes a moment, a spinner reads "Loading the board".

On a device, the first launch then shows a three-page introduction. The caption reads "Page 1 of 3", then "Page 2 of 3", then "Page 3 of 3".

Page 1: "Count one habit at a time." "Pin the habit you mean. The next tick lands there, not on a neighbor."
Page 2: "Tick only what you pinned." "A tick on any other habit is kept as a miss and does not add."
Page 3: "Peel a wrong tap." "Peel drops the latest tick or miss from today, then you pin again."

"Next" moves forward. "Back" appears from page 2 and returns one page. "Skip" on any page, or "Start" on page 3, leaves the introduction. If there are no habits yet, the app adds one named "Reps" and opens "Today".

"Settings" includes "Show introduction", which shows the same three pages again. Habits already on the device stay. "Skip" or "Start" does not add another "Reps" if a habit already exists.

## Screens
### Today
The home screen is titled "Today". Under the title is the date as one number, year then month then day, with no separators, from the device calendar. The line under that reads "Pin one habit, then tick."

Three icon buttons sit at the top. "Log" opens the log sheet. "Settings" opens settings. "Add a habit" opens "New habit".

If there are no habits, the screen shows "Add a habit to start." "Pin one habit, then tick. The count lands only on the habit you pinned." The button "Add a habit" opens "New habit".

With at least one habit, the large figure shows the selected habit’s name, a status of "Pinned", "Open", or "Empty", and today’s count. Under the count, the cap line is either "N. No daily cap" or "N of M. Within the daily cap" or "N of M. Over the daily cap".

The action row is "Pin", "Tick", and "Peel". "Pin" locks the selected habit. "Tick" tries to add one to the selected habit. "Peel" removes the latest tick or miss from today. A short line under the buttons states the result:

- Nothing pinned yet: "Choose a habit and pin it. Tick stays refused until then."
- The selected habit is pinned: "[name] is pinned. Tick adds one, then the pin releases."
- Another habit is pinned: "The pin is on [pinned name]. Tick on [selected name] records a miss."
- A tick landed: "One landed on [name]. Pin the next habit before you tick again."
- A tick missed the pin: "That tick missed the pin. [name] stayed the same."
- A tick with nothing pinned: "Nothing is pinned. Pin a habit, then tick."
- A peel succeeded: "The latest tick or miss from today was removed."
- A peel or other change was refused: "That change was not applied."
- The civil day rolled forward, and also after "Reset today" when a count was cleared: "A new day started. Yesterday closed at zero."

Below that is the "Habit board". Each slab shows the habit name and today’s count. The pinned habit is drawn larger, with corner brackets. Tap a slab to select it; the figure follows that habit. Press and hold the board to peel, the same as "Peel".

If the saved board cannot be read, one of these notes appears with "Retry": "The saved grid was unreadable. Chickostan restored the previous copy." or "The saved grid was unreadable. Chickostan started from an empty grid." If a save fails: "The grid could not be saved. The marks stay on screen until the next save." "Retry" loads again.

### Log
Opened from "Log". Title "Log". Close control is "Close".

If there are no habits: "Nothing to chart yet." "Add a habit, pin it, and tick. The week shows up here." The button is "Close".

Otherwise each habit has a seven-day bar chart. The axis uses the device’s short month-and-day form. The number beside the name is today’s count. The first habit’s chart is the large one.

Under the charts are "Ticks", "Misses", "Refused", "Removed", and "Closed days". An empty section says "None recorded." A filled section shows up to eight newest rows. Each row shows the habit name, a detail, the date number, and the time in the device’s short time style. Details are "Added one", "Missed the pin", "Refused before a pin", "Removed a tick", "Removed a miss", and "Day closed". A habit that no longer exists is labeled "Unknown".

### Settings
Title "Settings". Close control is "Close".

If there are no habits: "No habits yet." "Add one habit. You can rename it and set a daily cap here." "Add a habit" opens "New habit". The rest of settings is hidden until a habit exists.

With habits, the first row is "Contact and support", with `https://capstan-grid.pro/contact-us` under it. Tapping it opens that page.

Each habit is a row with its name and today’s count. Tapping it opens "Edit habit". "Add a habit" opens "New habit".

Further rows: "Daily caps", "Lock", "Habit list", "Ticks", "Misses", "Refused ticks", "Removed ticks".

Then "Reset today", "Erase all data", and "Show introduction".

"Reset today" asks "Reset today?" with "Every count for this date returns to zero." Confirm with "Reset today" or leave with "Cancel".

"Erase all data" asks "Erase every habit?" with "Habits and counts are removed. This cannot be undone." Confirm with "Erase all data" or leave with "Cancel". If the erase cannot finish, settings can show "The old grid could not be removed. Try the reset again." and "Retry".

### New habit and Edit habit
"New habit" opens from "Add a habit" and says "Name the habit." "Edit habit" says "Edit this habit." The sheet opened from Today’s "Add a habit" has "Close" at the top.

Fields: "Name" with placeholder "Habit name", and "Daily cap" with placeholder "Whole number". The keyboard has "Done".

"Save" is disabled until the name is not blank. An empty name shows "Enter a name." A cap that is not a whole number above zero shows "Use a whole number above zero, or leave the cap empty." Typing a minus sign or a decimal separator shows "Use a whole number. Negative values are refused." A blank cap means no cap. A refused save shows "That name was refused." or "That habit was refused."

"Edit habit" also has "Delete". That asks "Delete this habit?" with "The counts for this habit are removed with it." Confirm with "Delete" or leave with "Cancel". Deleting the pinned habit releases the pin. Deleting the last habit returns Today to the empty state.

### Daily caps
Title "Daily caps". "Set a daily cap, or leave it blank." With no habits: "Add a habit before you set a cap."

The first habit has a large field labeled "Whole number". Any further habits have a field labeled "Cap". Only digits are kept. "Save caps" stores every field. A blank field clears that cap. A value that is not a whole number above zero shows "Use a whole number above zero, or clear the field." and "Retry", which clears that message so you can edit again.

### Lock
Title "Lock". If nothing is pinned: "Pin a habit to set the lock." "Tick adds one to the pinned habit, then the lock releases. A tick on any other habit is a miss and does not add." The heading "Pin a habit" sits above one "Pin [name]" button per habit.

If a habit is pinned: "[name] is pinned." "Tick adds one to [name], then the lock releases. Pin another habit to move the lock." The pinned name, count, and "Pinned" are shown, with "Tick [name]". Other habits sit under "Move the lock", each as "Pin [name]".

### Habit list
Opened from "Habit list". Title "Habits".

Empty: "No habits yet." "Add a habit, pin it, then tick." "Add a habit" immediately adds a habit named "Reps". It does not open the naming sheet.

With habits, the lead is "Pin a habit. The next tick lands only on that habit." or, once one is pinned, "Tick the pinned habit. Pin another habit to move the lock." Each card shows the count, the name, "Pinned" or "Open", and, if a cap exists, "N of M". The button is "Pin [name]" or, on the pinned habit, "Tick [name]".

### Ticks
Title "Ticks". Empty: "No ticks yet." "Pin a habit on Today, then tick. Each add shows up here." The button is "Retry", which reloads. A filled list leads with the number of rows, then one row per tick: habit, "Added one", date number, and time.

### Misses
Title "Misses". Empty: "No misses today." "A tick on a habit that is not pinned is stored here and does not add." "Retry" reloads. A filled list shows every miss, not only today’s, then a panel "Misses by habit" with a count per habit. The line reads "This tick missed the pin and did not add. Pin that habit, then tick it on Today." The button is "Pin [name]" for the newest miss. It pins that habit. It does not switch to Today by itself.

### Refused
Opened from "Refused ticks". Title "Refused". Empty: "No refused ticks." "Tick before you pin, and the refusal is kept here without changing a count." "Retry" reloads. A filled list has the panel "Refused by habit". The line reads "A tick before a pin is refused. Pin the habit, then tick it on Today." The button is "Pin [name]" for the newest refusal.

### Removed
Opened from "Removed ticks". Title "Removed". Empty: "Nothing has been peeled." "Peel on Today removes the latest tick or miss for this date." "Retry" reloads. A filled list has the panel "What was removed", with "Removed ticks" and "Removed misses".

If the newest removal dropped a tick and that habit is already pinned: "The latest removal dropped a tick. Add it back onto today's count." The button "Add [name] back" adds one tick. If that habit is not pinned: "The latest removal dropped a tick. Pin the habit, then add it back from Today." The button is "Pin [name]". If the newest removal dropped a miss: "The latest removal dropped a miss. Pin the habit before the next tick." The button is "Pin [name]".

### Apple Watch
A companion also named "Chickostan" shows three static screens. It does not list habits, change counts, or mirror the iPhone board. The usual screen is "Today", "Pin one habit, then tick.", and the word "Tick", which is not a control. The other two read "Log" / "Seven days of ticks, misses, and removed counts." and "Settings" / "Caps, reset, and support live on iPhone."

## Features
- Named habits, each with today’s count.
- Pin one habit, then tick. A successful tick adds one and releases the pin.
- A tick on a habit that is not pinned is a miss and does not add. The pin stays where it was.
- A tick before any pin is refused and does not change a count.
- Peel removes the latest tick or miss from today.
- Optional daily cap per habit, shown as "Within the daily cap" or "Over the daily cap". Crossing the cap does not block further ticks.
- Seven-day chart per habit.
- Ledgers for ticks, misses, refused ticks, removed ticks, and closed days.
- Rename, delete, reset today, and erase every habit and count.
- Introduction can be shown again from "Show introduction".
- "Contact and support" opens `https://capstan-grid.pro/contact-us`.

## Behaviours that can look like bugs
- "Tick" does not add until a habit is pinned. The line is "Choose a habit and pin it. Tick stays refused until then." or "Nothing is pinned. Pin a habit, then tick." Pin the habit, then tick.
- After a tick lands, the pin releases on purpose. The line is "One landed on [name]. Pin the next habit before you tick again." Pin again before the next add.
- "Tick" on a habit that is not the pinned one does not add. The line is "That tick missed the pin. [name] stayed the same." Select the pinned habit, or pin the one you mean, then tick.
- "Peel" with nothing to remove today shows "That change was not applied." Tick or miss first, then peel. Peel only undoes today’s latest tick or miss. A count already cleared by "Reset today" or by a new day is not peeled back.
- "Pin", "Tick", and "Peel" dim for a fraction of a second after each tap, then work again.
- "Save" on "New habit" and "Edit habit" stays disabled until "Habit name" has text. A blank or invalid "Daily cap" stays on the sheet with "Enter a name." or "Use a whole number above zero, or leave the cap empty."
- "Save caps" stops on the first bad field and shows "Use a whole number above zero, or clear the field." "Retry" only clears that sentence.
- On the habit list, the empty-state "Add a habit" creates "Reps" immediately. Naming a habit is done from Settings or from Today’s "Add a habit".
- "Misses" empty copy says "No misses today.", but a filled list includes older misses too.
- The log sections "Ticks", "Misses", "Refused", "Removed", and "Closed days" show at most eight rows. The matching screens under Settings show the full lists.
- When the civil day changes, today’s counts show zero. Past days remain on the chart and under "Closed days". The line "A new day started. Yesterday closed at zero." also appears after "Reset today" when at least one count was cleared.
- Going over a daily cap still allows ticks. The figure changes to "Over the daily cap".
- Two habits may share a name. The app does not ask you to make them unique.
- "Show introduction" covers Today until "Skip" or "Start". It does not delete habits.

## Starter content and resume
On a device, finishing or skipping the introduction with an empty board adds one habit named "Reps", unpinned, with no daily cap and a count of zero. Habits, caps, pins, ticks, misses, refused ticks, and removed ticks remain on the device and are there on the next launch. There is no separate draft or in-progress session.

In the Simulator, a first empty launch can instead open already past the introduction, with "Pushups" (cap 40), "Espresso" (cap 4), "Pages" (cap 30), and "Water" (cap 8), earlier-day counts, and "Pushups" pinned. A device does not receive that sample board.

## Permissions
None.

## Absent
Login or accounts, in-app purchase, ads, analytics, shared or public user-generated content, an account-deletion flow, and an App Tracking Transparency prompt are absent. Habit names are typed on this device and are not posted. "Erase all data" removes the local habits and counts. It is not an account deletion.

## Data and support
Habits, counts, caps, and the log stay on this device. The support control is "Contact and support" in Settings. The address shown under it is `https://capstan-grid.pro/contact-us`. Tapping it opens that page.

## Scanning and health
None.

## Platform
Dates, chart labels, times, and counts follow the device calendar and locale. The number under "Today" is the civil date as eight digits, year, month, and day, with grouping turned off. There is no in-app region picker. The app is light appearance only, portrait only, on iPhone and iPad, full screen. It is not a Mac or visionOS app. Minimum iOS version is 17.0. The Apple Watch companion is display-name "Chickostan" and requires watchOS 26.0. It does not sync the board.

## Category
Lifestyle.
