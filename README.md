# Mission Control

A custom dashboard for tracking, managing, and optimizing OpenClaw workflows.

## Purpose

This repository contains the Mission Control dashboard and tooling for managing AI-assisted work. It serves as a central command center where you can view everything your OpenClaw (Poppy) is working on, track tasks, search memories, and coordinate work between you and your AI assistant.

## The Plan

### Phase 1: Core Infrastructure (Week 1-2)

**1.1 Dashboard Foundation**
- Create a simple HTML/CSS/JS dashboard
- Start with a single-page layout that loads data from JSON files
- No complex backend - just static files that I (Poppy) can update

**1.2 Data Storage**
- Use JSON files for all data (no database needed initially)
- Structure:
  - `data/tasks.json` - Task board data
  - `data/activity.json` - Activity feed
  - `data/calendar.json` - Scheduled tasks and reminders
  - `data/memory-index.json` - Searchable memory index

**1.3 File Organization**
```
mission-control/
├── dashboard/          # Web dashboard (HTML/CSS/JS)
│   ├── index.html     # Main dashboard
│   ├── css/
│   └── js/
├── data/              # JSON data files
├── docs/              # Documentation & guides
└── scripts/           # Utility scripts (optional)
```

### Phase 2: Core Components (Week 2-4)

**2.1 Activity Feed** 📋
- Real-time log of everything Poppy does
- Shows: timestamp, action, status, tokens used
- Filter by date, action type, or status
- Why: Critical for transparency when Poppy works autonomously

**2.2 Task Board** ✅
- Kanban-style board (To Do / In Progress / Done)
- Tasks assigned to "Martin" or "Poppy"
- Drag-and-drop would be nice, but start with simple lists
- Poppy updates this file automatically when working on tasks

**2.3 Calendar View** 📅
- Shows all scheduled cron jobs and reminders
- One-time tasks vs. recurring tasks
- Visual indicator of what's coming up
- Integration with the cron job we already set up (Wednesday reminders)

**2.4 Memory Search** 🔍
- Search interface for all memories
- Index MEMORY.md and memory/*.md files
- Tag-based filtering (work, personal, ideas, etc.)
- Show context around search results

### Phase 3: Advanced Features (Week 4-6)

**3.1 Team/Subagents View** 👥
- Visual representation of subagents when active
- Status indicators (idle, working, completed)
- What each subagent is working on
- "Office view" - just for fun, as Alex Finn suggested

**3.2 Content Pipeline** 📝
- For content creation workflows
- Stages: Ideas → Writing → Review → Published
- Track blog posts, videos, social content
- Store drafts and final versions

**3.3 Mission Statement Display** 🎯
- Prominent display of your mission statement
- Poppy references this for reverse-prompting
- "What is 1 task we can do to get closer to our mission?"

**3.4 Analytics/Insights** 📊
- Token usage tracking
- Tasks completed per week
- Time saved estimates
- Quick stats dashboard

### Phase 4: Integration & Polish (Week 6-8)

**4.1 Real-time Updates**
- Poppy can push updates to the dashboard
- Simple refresh mechanism or polling
- Notifications for important events

**4.2 Mobile-Friendly**
- Responsive design for phone/tablet
- Quick view of today's tasks and calendar

**4.3 Documentation**
- How-to guides for each feature
- Tips for getting the most out of Mission Control
- Integration examples

## Technical Approach

**Why Simple/Static First?**
- Faster to build and iterate
- No server maintenance
- I can update JSON files directly
- Easy to version control
- Can always add a backend later if needed

**Data Flow**
```
Poppy works → Updates JSON files → Dashboard reads JSON → You see updates
```

**Tools We'll Use**
- HTML/CSS/JS (vanilla, no frameworks needed initially)
- Simple grid/flexbox layout
- Local JSON files for data
- Git for version control
- Optional: lightweight CSS framework (Bulma, Tailwind) for styling

## Getting Started

1. **Phase 1 Setup** (This week)
   - Create basic HTML structure
   - Set up JSON data files
   - Verify I can read/write to these files

2. **First Component** (Next week)
   - Pick one: Activity Feed or Task Board
   - Build it out fully
   - Test the workflow

3. **Iterate** (Ongoing)
   - Add components one by one
   - Use it daily, see what works
   - Adjust based on actual usage

## Current Status

🚧 **Phase 1: Infrastructure Setup**
- ✅ Repository created
- ✅ Basic structure in place
- 🔄 Next: Create first HTML dashboard

## Notes & Philosophy

**As Alex Finn said:** "Your OpenClaw is useless without a Mission Control." But also: "You're allowed to have fun." This should be both useful AND enjoyable to use.

**Principles:**
- Start simple, add complexity only when needed
- Build what you'll actually use daily
- Make it easy for Poppy to update automatically
- Keep it fun - the "office view" doesn't have to be purely practical

---

Created by OpenClaw (Poppy) for Martin
Last updated: 2025-02-22
