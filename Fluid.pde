final int N = 64;
final int iter = 4;
final int SCALE = 10;  

int IX(int x, int y){
  x = constrain(x, 0, N-1);
  y = constrain(y, 0, N-1);  
 return x + y * N; 
}

class Fluid {
    int size;
    float dt;
    float diff;
    float visc;
    
    float[] s;
    float[] density;
    
    float[] Vx;
    float[] Vy;

    float[] Vx0;
    float[] Vy0; 
    
    Fluid(float dt, float diffusion, float viscosity) {
      this.size = N;
      this.dt = dt;
      this.diff = diffusion;
      this.visc = viscosity;
      
      this.s = new float[N*N];
      this.density = new float[N*N];
      
      this.Vx = new float[N*N];
      this.Vy = new float[N*N];
      
      this.Vx0 = new float[N*N];
      this.Vy0 = new float[N*N];
    }
    
    void step() {
      float visc     = this.visc;
      float diff     = this.diff;
      float dt       = this.dt;
      float[] Vx      = this.Vx;
      float[] Vy      = this.Vy;
      float[] Vx0     = this.Vx0;
      float[] Vy0     = this.Vy0;
      float[] s       = this.s;
      float[] density = this.density;

      diffuse(1, Vx0, Vx, visc, dt);
      diffuse(2, Vy0, Vy, visc, dt);

      project(Vx0, Vy0, Vx, Vy);

      advect(1, Vx, Vx0, Vx0, Vy0, dt);
      advect(2, Vy, Vy0, Vx0, Vy0, dt);  

      project(Vx, Vy, Vx0, Vy0);

      diffuse(0, s, density, diff, dt);
      advect(0, density, s, Vx, Vy, dt);
    }
    
    void addDensity(int x, int y, float amount) {
      int index = IX(x, y);
      this.density[index] += amount;
    }
    
    void addVelocity(int x, int y, float amountX, float amountY) {
     int index = IX(x, y);
     this.Vx[index] += amountX;
     this.Vy[index] += amountY;
    }
    
    float curl(int x, int y) {
     return Vx[IX(x, y+1)]-Vx[IX(x, y-1)]+Vy[IX(x-1, y)]-Vy[IX(x+1, y)]; 
    }
    
    void vorticityConfinement(float dt, float vorticity) {
     float dx, dy, len;
     for(int x = 2; x < N - 3; x++) {
      for(int y = 2; y < N - 3; y++) {
        dx = abs(curl(x+0, y-1)) - abs(curl(x+0, y+1));
        dy = abs(curl(x+1, y+0)) - abs(curl(x-1, y+0));
        len = sqrt(sq(dx) + sq(dy)) + 1e-5;
        dx = vorticity/len*dx;
        dy = vorticity/len*dy;
        Vx[IX(x, y)] += curl(x, y)*dx;
        Vy[IX(x, y)] += curl(x, y)*dy;
      }
     }
    }
    
    void renderD() {
     for(int i = 0; i < N; i++) {
      for(int j = 0; j < N; j++) {
       float x = i * SCALE;
       float y = j * SCALE;
       float d = this.density[IX(i, j)];
       fill(d);
       noStroke();
       square(x, y, SCALE);
      }
     }
    }
}
