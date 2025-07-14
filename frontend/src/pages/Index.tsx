import { useState, useEffect } from 'react';
import { Note } from '@/types/note';
import { noteService } from '@/services/noteService';
import { NotesGrid } from '@/components/notes/NotesGrid';
import { NoteEditor } from '@/components/notes/NoteEditor';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Plus, Search, StickyNote } from 'lucide-react';
import { useToast } from '@/hooks/use-toast';

const Index = () => {
  const [notes, setNotes] = useState<Note[]>([]);
  const [filteredNotes, setFilteredNotes] = useState<Note[]>([]);
  const [searchQuery, setSearchQuery] = useState('');
  const [isEditorOpen, setIsEditorOpen] = useState(false);
  const [editingNote, setEditingNote] = useState<Note | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const { toast } = useToast();

  // Load notes on component mount
  useEffect(() => {
    loadNotes();
  }, []);

  // Filter notes based on search query
  useEffect(() => {
    if (searchQuery.trim()) {
      const filtered = notes.filter(note => 
        note.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
        note.content.toLowerCase().includes(searchQuery.toLowerCase())
      );
      setFilteredNotes(filtered);
    } else {
      setFilteredNotes(notes);
    }
  }, [notes, searchQuery]);

  /**
   * Load all notes from backend
   * TODO: This connects to your Python backend API
   */
  const loadNotes = async () => {
    setIsLoading(true);
    try {
      const response = await noteService.getAllNotes();
      if (response.success && response.data) {
        setNotes(response.data);
      } else {
        toast({
          title: 'Error',
          description: response.error || 'Failed to load notes',
          variant: 'destructive'
        });
      }
    } catch (error) {
      toast({
        title: 'Error',
        description: 'Failed to load notes',
        variant: 'destructive'
      });
    } finally {
      setIsLoading(false);
    }
  };

  /**
   * Handle creating a new note
   * TODO: This will call your Python backend API
   */
  const handleCreateNote = async (noteData: { title: string; content: string; color?: string }) => {
    try {
      const response = await noteService.createNote(noteData);
      if (response.success && response.data) {
        setNotes([response.data, ...notes]);
        toast({
          title: 'Success',
          description: 'Note created successfully'
        });
      } else {
        toast({
          title: 'Error',
          description: response.error || 'Failed to create note',
          variant: 'destructive'
        });
      }
    } catch (error) {
      toast({
        title: 'Error',
        description: 'Failed to create note',
        variant: 'destructive'
      });
    }
  };

  /**
   * Handle updating an existing note
   * TODO: This will call your Python backend API
   */
  const handleUpdateNote = async (noteData: { title: string; content: string; color?: string }) => {
    if (!editingNote) return;

    try {
      const response = await noteService.updateNote({
        id: editingNote.id,
        ...noteData
      });
      
      if (response.success && response.data) {
        setNotes(notes.map(note => 
          note.id === editingNote.id ? response.data! : note
        ));
        toast({
          title: 'Success',
          description: 'Note updated successfully'
        });
      } else {
        toast({
          title: 'Error',
          description: response.error || 'Failed to update note',
          variant: 'destructive'
        });
      }
    } catch (error) {
      toast({
        title: 'Error',
        description: 'Failed to update note',
        variant: 'destructive'
      });
    }
  };

  /**
   * Handle deleting a note
   * TODO: This will call your Python backend API
   */
  const handleDeleteNote = async (noteId: string) => {
    try {
      const response = await noteService.deleteNote({ id: noteId });
      if (response.success) {
        setNotes(notes.filter(note => note.id !== noteId));
        toast({
          title: 'Success',
          description: 'Note deleted successfully'
        });
      } else {
        toast({
          title: 'Error',
          description: response.error || 'Failed to delete note',
          variant: 'destructive'
        });
      }
    } catch (error) {
      toast({
        title: 'Error',
        description: 'Failed to delete note',
        variant: 'destructive'
      });
    }
  };

  const handleEditNote = (note: Note) => {
    setEditingNote(note);
    setIsEditorOpen(true);
  };

  const handleNewNote = () => {
    setEditingNote(null);
    setIsEditorOpen(true);
  };

  const handleCloseEditor = () => {
    setIsEditorOpen(false);
    setEditingNote(null);
  };

  const handleSaveNote = (noteData: { title: string; content: string; color?: string }) => {
    if (editingNote) {
      handleUpdateNote(noteData);
    } else {
      handleCreateNote(noteData);
    }
  };

  if (isLoading) {
    return (
      <div className="min-h-screen bg-background flex items-center justify-center">
        <div className="text-center space-y-2">
          <StickyNote className="h-8 w-8 mx-auto animate-pulse text-primary" />
          <p className="text-muted-foreground">Loading notes...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <header className="border-b border-border bg-card">
        <div className="max-w-7xl mx-auto px-4 py-4">
          <div className="flex items-center justify-between mb-4">
            <div className="flex items-center gap-2">
              <StickyNote className="h-6 w-6 text-primary" />
              <h1 className="text-xl font-semibold text-foreground">Notes</h1>
            </div>
            <Button onClick={handleNewNote} className="flex items-center gap-2">
              <Plus className="h-4 w-4" />
              New Note
            </Button>
          </div>
          
          {/* Search */}
          <div className="relative max-w-md">
            <Search className="absolute left-3 top-3 h-4 w-4 text-muted-foreground" />
            <Input
              placeholder="Search notes..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="pl-10"
            />
          </div>
        </div>
      </header>

      {/* Notes Grid */}
      <main className="max-w-7xl mx-auto">
        <NotesGrid
          notes={filteredNotes}
          onEditNote={handleEditNote}
          onDeleteNote={handleDeleteNote}
        />
      </main>

      {/* Note Editor Modal */}
      <NoteEditor
        note={editingNote}
        isOpen={isEditorOpen}
        onClose={handleCloseEditor}
        onSave={handleSaveNote}
      />
    </div>
  );
};

export default Index;
