import { useState, useEffect } from 'react';
import { Note } from '@/types/note';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Textarea } from '@/components/ui/textarea';
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Save, X, Palette } from 'lucide-react';

interface NoteEditorProps {
  note?: Note | null;
  isOpen: boolean;
  onClose: () => void;
  onSave: (noteData: { title: string; content: string; color?: string }) => void;
}

const noteColors = [
  '#f9e2af', // Yellow
  '#fab387', // Peach  
  '#f38ba8', // Pink
  '#cba6f7', // Mauve
  '#89b4fa', // Blue
  '#94e2d5', // Teal
  '#a6e3a1', // Green
  '#f2cdcd', // Flamingo
];

export function NoteEditor({ note, isOpen, onClose, onSave }: NoteEditorProps) {
  const [title, setTitle] = useState('');
  const [content, setContent] = useState('');
  const [selectedColor, setSelectedColor] = useState<string>('');
  const [showColorPicker, setShowColorPicker] = useState(false);

  useEffect(() => {
    if (note) {
      setTitle(note.title);
      setContent(note.content);
      setSelectedColor(note.color || '');
    } else {
      setTitle('');
      setContent('');
      setSelectedColor('');
    }
  }, [note]);

  const handleSave = () => {
    if (!title.trim() && !content.trim()) return;
    
    onSave({
      title: title.trim(),
      content: content.trim(),
      color: selectedColor || undefined
    });
    
    handleClose();
  };

  const handleClose = () => {
    setTitle('');
    setContent('');
    setSelectedColor('');
    setShowColorPicker(false);
    onClose();
  };

  return (
    <Dialog open={isOpen} onOpenChange={handleClose}>
      <DialogContent className="max-w-md">
        <DialogHeader>
          <DialogTitle>
            {note ? 'Edit Note' : 'Create New Note'}
          </DialogTitle>
        </DialogHeader>
        
        <div className="space-y-4">
          <Input
            placeholder="Note title..."
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            className="font-semibold"
          />
          
          <Textarea
            placeholder="Start writing your note..."
            value={content}
            onChange={(e) => setContent(e.target.value)}
            rows={8}
            className="resize-none"
          />
          
          <div className="space-y-2">
            <Button
              variant="outline"
              size="sm"
              onClick={() => setShowColorPicker(!showColorPicker)}
              className="flex items-center gap-2"
            >
              <Palette className="h-4 w-4" />
              Color
            </Button>
            
            {showColorPicker && (
              <div className="flex gap-2 flex-wrap">
                <Button
                  variant={selectedColor === '' ? 'default' : 'outline'}
                  size="sm"
                  onClick={() => setSelectedColor('')}
                  className="w-8 h-8 p-0 bg-card border"
                >
                  <X className="h-3 w-3" />
                </Button>
                {noteColors.map((color) => (
                  <Button
                    key={color}
                    variant={selectedColor === color ? 'default' : 'outline'}
                    size="sm"
                    onClick={() => setSelectedColor(color)}
                    className="w-8 h-8 p-0 border-2"
                    style={{ backgroundColor: color }}
                  />
                ))}
              </div>
            )}
          </div>
          
          <div className="flex justify-end gap-2 pt-4">
            <Button variant="outline" onClick={handleClose}>
              Cancel
            </Button>
            <Button onClick={handleSave} disabled={!title.trim() && !content.trim()}>
              <Save className="h-4 w-4 mr-2" />
              {note ? 'Update' : 'Create'}
            </Button>
          </div>
        </div>
      </DialogContent>
    </Dialog>
  );
}